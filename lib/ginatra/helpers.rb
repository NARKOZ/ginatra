require 'digest/md5'

module Ginatra
  # Helpers used in the views, and not only.
  module Helpers
    include Rack::Utils
    alias_method :h, :escape_html

    # Checks X-PJAX header
    def is_pjax?
      request.env['HTTP_X_PJAX']
    end

    # Sets title for pages
    def title(*args)
      @title ||= []
      @title_options ||= { headline: nil, sitename: nil }
      options = args.last.is_a?(Hash) ? args.pop : {}

      @title += args
      @title_options.merge!(options)

      t = @title.clone
      t << @title_options[:headline]
      t << @title_options[:sitename]
      t.compact.join ' - '
    end

    # Constructs the URL used in the layout's base tag
    def prefix_url(rest_of_url='')
      prefix = Ginatra.config.prefix.to_s

      if prefix.length > 0 && prefix[-1].chr == '/'
        prefix.chop!
      end

      "#{prefix}/#{rest_of_url}"
    end

    # Returns hint to set repository description
    def empty_description_hint_for(repo)
      return '' unless repo.description.empty?
      hint_text = "Edit `#{repo.path}description` file to set the repository description."
      "<span class='icon-exclamation-sign' title='#{hint_text}'></span>"
    end

    # Returns file icon depending on filemode
    def file_icon(filemode)
      case filemode
        # symbolic link (120000)
        when 40960 then "<span class='icon-share-alt'></span>"
        # executable file (100755)
        when 33261 then "<span class='icon-asterisk'></span>"
        else "<span class='icon-file'></span>"
      end
    end

    # Takes an email and returns an image tag with gravatar
    #
    # @param [String] email the email address
    # @param [Hash] options alt, class and size options for image tag
    # @return [String] html image tag
    def gravatar_image_tag(email, options={})
      alt = options.fetch(:alt, email.gsub(/@\S*/, ''))
      size = options.fetch(:size, 40)
      url = "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=#{size}"

      "<img src='#{url}' alt='#{alt}' height='#{size}' width='#{size}'#{" class='#{options[:class]}'" if options[:class]}>"
    end

    # Reformats the date into a user friendly date with html entities
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

    # Returns a string including the link to download a patch for a certain
    # commit to the repo
    #
    # @param [Rugged::Commit] commit the commit you want a patch for
    # @param [String] repo_param the url-sanitised name for the repo
    #   (for the link path)
    #
    # @return [String] the HTML link to the patch
    def patch_link(commit, repo_param)
      patch_url = prefix_url("#{repo_param}/commit/#{commit.oid}.patch")
      "<a href='#{patch_url}'>Download Patch</a>"
    end

    # Spits out a HTML link to the atom feed for a given ref of a given repo
    #
    # @param [Sting] repo_param the url-sanitised-name of a given repo
    # @param [String] ref the ref to link to.
    #
    # @return [String] the HTML containing the link to the feed.
    def atom_feed_url(repo_param, ref=nil)
      ref.nil? ? prefix_url("#{repo_param}.atom") : prefix_url("#{repo_param}/#{ref}.atom")
    end

    # Returns a HTML (+<ul>+) list of the files modified in a given commit.
    #
    # It includes classes for added/modified/deleted and also anchor links
    # to the diffs for further down the page.
    #
    # @param [Rugged::Commit] commit the commit you want the list of files for
    #
    # @return [String] a +<ul>+ with lots of +<li>+ children.
    def file_listing(diff)
      list = []
      diff.deltas.each_with_index do |delta, index|
        if delta.deleted?
          list << "<li class='deleted'><span class='icon-remove'></span> <a href='#file-#{index + 1}'>#{delta.new_file[:path]}</a></li>"
        elsif delta.added?
          list << "<li class='added'><span class='icon-ok'></span> <a href='#file-#{index + 1}'>#{delta.new_file[:path]}</a></li>"
        elsif delta.modified?
          list << "<li class='changed'><span class='icon-edit'></span> <a href='#file-#{index + 1}'>#{delta.new_file[:path]}</a></li>"
        end
      end
      "<ul class='unstyled'>#{list.join}</ul>"
    end

    # Highlights commit diff
    #
    # @param [Rugged::Hunk] diff hunk for highlighting
    #
    # @return [String] highlighted HTML.code
    def highlight_diff(hunk)
      lines = []
      lines << hunk.header

      hunk.each_line do |line|
        if line.context?
          lines << "  #{line.content}"
        elsif line.deletion?
          lines << "- #{line.content}"
        elsif line.addition?
          lines << "+ #{line.content}"
        end
      end

      formatter = Rouge::Formatters::HTML.new
      lexer     = Rouge::Lexers::Diff.new

      source   = lines.join
      encoding = source.encoding
      source   = source.force_encoding(Encoding::UTF_8)

      hd = formatter.format lexer.lex(source)
      hd.force_encoding encoding
    end

    # Highlights blob source
    #
    # @param [Rugged::Blob] blob to highlight source
    #
    # @return [String] highlighted HTML.code
    def highlight_source(source, filename='')
      source    = source.force_encoding(Encoding::UTF_8)
      formatter = Rouge::Formatters::HTML.new(line_numbers: true)
      lexer     = Rouge::Lexer.guess_by_filename(filename)

      if lexer == Rouge::Lexers::PlainText
        lexer = Rouge::Lexer.guess_by_source(source) || Rouge::Lexers::PlainText
      end

      formatter.format lexer.lex(source)
    end

    # Formats the text to remove multiple spaces and newlines, and then inserts
    # HTML linebreaks.
    #
    # Brought from Rails: ActionView::Helpers::TextHelper#simple_format
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
    # @param [DateTime] datetime the date to format
    # @return [String] the formatted datetime
    def rfc_date(datetime)
      datetime.strftime("%Y-%m-%dT%H:%M:%SZ") # 2003-12-13T18:30:02Z
    end

    # Returns the Hostname of the given install, for use in the atom feeds.
    #
    # @return [String] the hostname of the server. Respects HTTP-X-Forwarded-For
    def hostname
      (request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/) ? request.env['HTTP_X_FORWARDED_SERVER'] : request.env['HTTP_HOST']
    end
  end
end
