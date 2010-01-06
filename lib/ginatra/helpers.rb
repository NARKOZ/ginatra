require "digest/md5"
require "open4"

module Ginatra
  # Helpers used in the views usually,
  # but not exclusively.
  module Helpers

    # constructs the URL used in the layout's base tag
    def prefix_url(rest_of_url="")
      prefix = Ginatra::Config[:prefix].to_s

      if prefix.length > 0 && prefix[-1].chr == "/"
        prefix.chop!
      end

      "#{prefix}/#{rest_of_url}"
    end

    # takes an email and returns a url to a secure gravatar
    #
    # @param [String] email the email address
    # @return [String] the url to the gravatar
    def gravatar_url(email)
      "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=40"
    end

    # reformats the date into a user friendly date with html entities
    #
    # @param [#strftime] date object to format nicely
    # @return [String] html string formatted using
    #   +"%b %d, %Y &ndash; %H:%M"+
    def nicetime(date)
      date.strftime("%b %d, %Y &ndash; %H:%M")
    end

    # displays the actor box easily.
    #
    # Internally, it calls the +#partial+ method
    # @see Sinatra::Partials#partial
    #
    # @param [Grit::Actor] actor the Grit Actor Object
    # @param [#to_s] role the role that the object has.
    # @param [#strftime] date the date that the actor acted on.
    #
    # @return [String] a string that contains the box for the actor.
    def actor_box(actor, role, date)
      partial(:actor_box, :locals => { :actor => actor, :role => role, :date => date })
    end

    # works out what actor boxes need to be displayed.
    #
    # Will always display the committer box, and will only display
    # the author box if it's different to the committer
    #
    # @param [Grit::Commit] commit the commit in question
    # @return [String] a string representing the HTML actor boxes
    def actor_boxes(commit)
      o = actor_box(commit.committer, :committer, commit.committed_date)
      if commit.author.name != commit.committer.name
        o = actor_box(commit.author, :author, commit.authored_date) + o
      end
    end

    # spits out a link to a certain reference.
    #
    # @param [Grit::Ref] ref grit ref object
    # @param [String] repo_param the url-sanitised-name for the repo
    #   (for the link path)
    #
    # @return [String] HTML link to the given ref with class attached.
    def commit_ref(ref, repo_param)
      ref_class = ref.class.to_s.split("::")[1].to_s
      "<a class=\"ref #{ref_class}\" href=\"" + prefix_url("#{repo_param}/#{ref.name}") + "\">#{ref.name}</a>"
    end

    # calls +Ginatra::Helpers#commit_ref+ for each ref in the commit
    #
    # @see Ginatra::Helpers#commit_ref
    #
    # @param [Grit::Commit] commit grit commit object
    # @param [String] repo_param the url-sanitised-name for the repo
    #   (for the link path)
    #
    # @return [String] HTML containing all the ref links
    def commit_refs(commit, repo_param)
      commit.refs.map{ |r| commit_ref(r, repo_param) }.join("\n")
    end

    # returns a string including the link to download a certain 
    # tree of the repo
    #
    # @param [Grit::Tree] tree the tree you want an archive link for
    # @param [String] repo_param the url-sanitised-name of the repo
    #   (for the link path)
    #
    # @return [String] the HTML link to the archive.
    def archive_link(tree, repo_param)
      "<a class=\"download\" href=\"" + prefix_url("#{repo_param}/archive/#{tree.id}.tar.gz") + "\" title=\"Download a tar.gz snapshot of this Tree\">Download Archive</a>"
    end

    # returns a string including the link to download a patch for a certain
    # commit to the repo
    #
    # @param [Grit::Commit] commit the commit you want a patch for
    # @param [String] repo_param the url-sanitised name for the repo
    #   (for the link path)
    #
    # @return [String] the HTML link to the patch
    def patch_link(commit, repo_param)
      "<a class=\"download\" href=\"" + prefix_url("#{repo_param}/commit/#{commit.id}.patch") + "\" title=\"Download a patch file of this Commit\">Download Patch</a>"
    end

    # returns a HTML (+<ul>+) list of the files altered in a given commit.
    #
    # It includes classes for added/altered/deleted and also anchor links 
    # to the diffs for further down the page.
    #
    # @param [Grit::Commit] commit the commit you want the list of files for
    #
    # @return [String] a +<ul>+ with lots of +<li>+ children.
    def file_listing(commit)
      # The only reason this doesn't work 100% of the time is because grit doesn't :/
      # if i find a fix, it'll go upstream :D
      count = 0
      out = commit.diffs.map do |diff|
        count = count + 1
        if diff.deleted_file
          %(<li class='file_rm'><a href='#file_#{count}'>#{diff.a_path}</a></li>)
        else
          cla = diff.new_file ? "add" : "diff"
          %(<li class='file_#{cla}'><a href='#file_#{count}'>#{diff.a_path}</a></li>)
        end
      end
      "<ul id='files'>#{out.join}</ul>"
    end

    # Formats the text to remove multiple spaces and newlines, and then inserts
    # HTML linebreaks.
    #
    # Stolen from rails: ActionView::Helpers::TextHelper#simple_format
    # and simplified to just use <p> tags without any options, then modified 
    # more later.
    #
    # @param [String] text the text you want formatted
    # 
    # @return [String] the formatted text
    def simple_format(text)
      text.gsub!(/ +/, " ")
      text.gsub!(/\r\n?/, "\n")
      text.gsub!(/\n/, "<br />\n")
      text
    end

    # Cleans up the particularly volatile parts of HTML 
    # and replaces them with their entities. Replaces the following 
    # characters:
    #  - &
    #  - >
    #  - <
    #  - '
    #
    # If you are using this with #simple_format, do not forget to call
    # this one first, then put in unsanitised linebreaks. The other way around
    # is full of fail.
    #
    # stolen from rails: ERB::Util
    #
    # @see Ginatra::Helpers#simple_format
    #
    # @param [#to_s] clean_me the object to clean.
    #
    # @return [String] the cleaned html text.
    def html_escape(clean_me)
      clean_me.to_s.gsub(/[&"<>]/) do |special|
        { '&' => '&amp;',
          '>' => '&gt;',
          '<' => '&lt;',
          '"' => '&quot;' }[special]
      end
    end
    alias :h :html_escape

    # Truncates a given text to a certain number of letters, including a special ending if needed.
    #
    # Stolen and bastardised from rails
    # 
    # @param [String] text the text to truncate
    # @option options [Integer] :length   (30) the length you want the output string
    # @option options [String]  :omission ("...") the string to show an omission.
    #
    # @return [String] the truncated text.
    def truncate(text, options={})
        options[:length] ||= 30
        options[:omission] ||= "..."

      if text
        l = options[:length] - options[:omission].length
        chars = text
        stop = options[:separator] ? (chars.rindex(options[:separator], l) || l) : l
        (chars.length > options[:length] ? chars[0...stop] + options[:omission] : text).to_s
      end
    end

    # Returns the rfc representation of a date, for use in the atom feeds.
    #
    # stolen from Marley
    #
    # @param [DateTime] datetime the date to format
    # @return [String] the formatted datetime
    def rfc_date(datetime)
      datetime.strftime("%Y-%m-%dT%H:%M:%SZ") # 2003-12-13T18:30:02Z
    end

    # Returns the Hostname of the given install. 
    # used in the atom feeds.
    #
    # stolen from Marley
    # 
    # @return [String] the hostname of the server. Respects HTTP-X-Forwarded-For
    def hostname
      (request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/) ? request.env['HTTP_X_FORWARDED_SERVER'] : request.env['HTTP_HOST']
    end

    # Spits out a HTML link to the atom feed for a given ref of a given repo
    #
    # @param [Sting] repo_param the url-sanitised-name of a given repo
    # @param [String] ref the ref to link to.
    #
    # @return [String] the HTML containing the link to the feed.
    def atom_feed_link(repo_param, ref=nil)
      "<a href=\"" + prefix_url("#{repo_param}#{"/#{ref}" if !ref.nil?}.atom") + "\" title=\"Atom Feed\" class=\"atom\">Feed</a>"
    end

    def pygmentize(content, filename=nil)
      type = !filename ? "diff" : pygmentize_type(filename)
      html_output = ''
      Open4.popen4("pygmentize -l #{type} -f html") do |pid, stdin, stdout, stderr|
        stdin.puts content
        stdin.close
        html_output = stdout.read.strip
        [stdout, stderr].each {|io| io.close }
      end
      html_output
    rescue Errno::ENOENT
      return "<div class=\"highlight\"><pre>#{content}</pre></div>"
    end

    def pygmentize_type(filename)
      type =''
      Open4.popen4("pygmentize -N #{filename}") do |pid, stdin, stdout, stderr|
        type = stdout.read.strip
        [stdin, stdout, stderr].each {|io| io.close }
      end
      type
    rescue Errno::ENOENT
      return "text"
    end
  end
end
