require "digest/md5"

module Ginatra
  # Helpers used in the views usually,
  # but not exclusively.
  module Helpers
    include Rack::Utils
    alias_method :h, :escape_html

    # checks X-PJAX header
    def is_pjax?
      request.env['HTTP_X_PJAX']
    end

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
    def gravatar_url(email, size=40)
      "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}"
    end

    # reformats the date into a user friendly date with html entities
    #
    # @param [#strftime] date object to format nicely
    # @return [String] html string formatted using
    #   +"%b %d, %Y &ndash; %H:%M"+
    def nicetime(date)
      date.strftime("%b %d, %Y &ndash; %H:%M")
    end

    # Returns an html time tag for the given time
    #
    # @param [Time] time object
    # @return [String] time tag formatted using
    #   +"%B %d, %Y %H:%M"+
    def time_tag(time)
      datetime = time.strftime('%Y-%m-%dT%H:%M:%S%z')
      title = time.strftime('%Y-%m-%d %H:%M:%S')
      "<time datetime='#{datetime}' title='#{title}'>#{time.strftime('%B %d, %Y %H:%M')}</time>"
    end

    # spits out a link to a certain reference.
    #
    # @param [Grit::Ref] ref grit ref object
    # @param [String] repo_param the url-sanitised-name for the repo
    #   (for the link path)
    #
    # @return [String] HTML link to the given ref with class attached.
    def commit_ref(ref, repo_param)
      ref_url = prefix_url("#{repo_param}/#{ref.name}")
      "<a href='#{ref_url}'>#{ref.name}</a>"
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
      commit.refs.map { |r| commit_ref(r, repo_param) }.join("\n")
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
      archive_url = prefix_url("#{repo_param}/archive/#{tree.id}.tar.gz")
      "<a href='#{archive_url}'>Download Archive</a>"
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
      patch_url = prefix_url("#{repo_param}/commit/#{commit.id}.patch")
      "<a href='#{patch_url}'>Download Patch</a>"
    end

    # Spits out a HTML link to the atom feed for a given ref of a given repo
    #
    # @param [Sting] repo_param the url-sanitised-name of a given repo
    # @param [String] ref the ref to link to.
    #
    # @return [String] the HTML containing the link to the feed.
    def atom_feed_link(repo_param, ref=nil)
      feed_url = ref.nil? ? prefix_url("#{repo_param}.atom") : prefix_url("#{repo_param}/#{ref}.atom")
      "<a href='#{feed_url}'>Feed</a>"
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
      list = []
      commit.diffs.each_with_index do |diff, index|
        if diff.deleted_file
          list << "<li class='deleted'><i class='icon-remove'></i> <a href='#file-#{index + 1}'>#{diff.a_path}</a></li>"
        else
          cls = diff.new_file ? "added" : "changed"
          ico = diff.new_file ? "icon-ok" : "icon-edit"
          list << "<li class='#{cls}'><i class='#{ico}'></i> <a href='#file-#{index + 1}'>#{diff.a_path}</a></li>"
        end
      end
      "<ul class='unstyled'>#{list.join}</ul>"
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
  end
end
