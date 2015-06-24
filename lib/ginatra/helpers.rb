require 'digest/md5'

module Ginatra
  # Helpers used in the views, and not only.
  module Helpers
    # Escapes string to HTML entities
    def h(text)
      Rack::Utils.escape_html(text)
    end

    # Checks X-PJAX header
    def pjax?
      request.env['HTTP_X_PJAX']
    end

    # Sets title for pages
    def title(*args)
      @title ||= []
      @title_options ||= { headline: nil,
                           sitename: h(Ginatra.config.sitename) }
      options = args.last.is_a?(Hash) ? args.pop : {}

      @title += args
      @title_options.merge!(options)

      t = @title.clone
      t << @title_options[:headline]
      t << @title_options[:sitename]
      t.compact.join ' - '
    end

    # Constructs the URL used in the layout's base tag
    def prefix_url(rest_of_url = '')
      prefix = Ginatra.config.prefix.to_s

      prefix.chop! if prefix.length > 0 && prefix[-1].chr == '/'

      "#{prefix}/#{rest_of_url}"
    end

    # Returns hint to set repository description
    def empty_description_hint_for(repo)
      return '' unless repo.description.empty?
      hint_text = "Edit `#{repo.path}description` file to"\
                  " set the repository description."
      "<img src='/img/exclamation-circle.svg' "\
      "title='#{hint_text}' alt='hint' class='icon'>"
    end

    # Returns file icon depending on filemode
    def file_icon(filemode)
      case filemode
      # symbolic link (120000)
      when 40_960 then "<img src='/img/mail-forward.svg'"\
                       " alt='symbolic link' class='icon'>"
      # executable file (100755)
      when 33_261 then "<img src='/img/asterisk.svg'"\
                       " alt='executable file' class='icon'>"
      else "<img src='/img/file.svg' alt='file' class='icon'>"
      end
    end

    # Masks original email
    def secure_mail(email)
      local, domain = email.split('@')
      "#{local[0..3]}...@#{domain}"
    end

    # Takes an email and returns an image tag with gravatar
    #
    # @param [String] email the email address
    # @param [Hash] options alt, class and size options for image tag
    # @return [String] html image tag
    def gravatar_image_tag(email, options = {})
      alt = options.fetch(:alt, email.gsub(/@\S*/, ''))
      size = options.fetch(:size, 40)
      url = 'https://secure.gravatar.com/avatar/'\
            "#{Digest::MD5.hexdigest(email)}?s=#{size}"

      if options[:lazy]
        tag = lazy_option_tag(url, placeholder, alt, size, options)
      else
        tag = image_tag(url, placeholder, alt, size, options)
      end

      tag
    end

    # image placeholder
    def placeholder
      'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP'\
      '///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'
    end

    # Generates a tag with lazy options
    def lazy_option_tag(url, placeholder, alt, size, options)
      "<img data-original='#{url}' src='#{placeholder}' "\
      "alt='#{h alt}' height='#{size}' width='#{size}' "\
      "class='js-lazy #{options[:class]}'>"
    end

    # Generates an image tag with no lazy option
    def image_tag(url, placeholder, alt, size, options)
      "<img src='#{url}' alt='#{h alt}' height='#{size}' "\
      "width='#{size}'"\
      "#{" class='#{options[:class]}'" if options[:class]}>"
    end

    # Reformats the date into a user friendly date with html entities
    #
    # @param [#strftime] date object to format nicely
    # @return [String] html string formatted using
    #   +"%b %d, %Y &ndash; %H:%M"+
    def nicetime(date)
      date.strftime('%b %d, %Y &ndash; %H:%M')
    end

    # Returns an html time tag for the given time
    #
    # @param [Time] time object
    # @return [String] time tag formatted using
    #   +"%B %d, %Y %H:%M"+
    def time_tag(time)
      datetime = time.strftime('%Y-%m-%dT%H:%M:%S%z')
      title = time.strftime('%Y-%m-%d %H:%M:%S')
      "<time datetime='#{datetime}' title='#{title}'>"\
      "#{time.strftime('%B %d, %Y %H:%M')}</time>"
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
    def atom_feed_url(repo_param, ref = nil)
      ref.nil? ? prefix_url("#{repo_param}.atom") :
                 prefix_url("#{repo_param}/#{ref}.atom")
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
        file_list_item(delta, index, list)
      end
      "<ul class='list-unstyled'>#{list.join}</ul>"
    end

    # Returns a HTML(+<li>+) tag for each file listing
    def file_list_item(delta, index, list)
      if delta.deleted?
        list << delta_deleted(delta, index)
      elsif delta.added?
        list << delta_added(delta, index)
      elsif delta.modified?
        list << delta_modified(delta, index)
      end
    end
    # Tag if file deleted
    def delta_deleted(delta, index)
      "<li class='deleted'><img src='/img/minus-square.svg'"\
      " alt='deleted' class='icon'> <a href='#file-#{index + 1}'>"\
      "#{delta.new_file[:path]}</a></li>"
    end

    # Tag if file added
    def delta_added(delta, index)
      "<li class='added'><img src='/img/plus-square.svg'"\
      " alt='added' class='icon'> <a href='#file-#{index + 1}'>"\
      "#{delta.new_file[:path]}</a></li>"
    end

    # Tag if file modified
    def delta_modified(delta, index)
      "<li class='changed'><img src='/img/edit.svg'"\
      " alt='modified' class='icon'> "\
      "<a href='#file-#{index + 1}'>"\
      "#{delta.new_file[:path]}</a></li>"
    end

    # Highlights commit diff
    #
    # @param [Rugged::Hunk] diff hunk for highlighting
    #
    # @return [String] highlighted HTML.code
    def highlight_diff(hunk)
      lines = print_lines(hunk)

      formatter = Rouge::Formatters::HTML.new
      lexer     = Rouge::Lexers::Diff.new
      source   = lines.join
      encoding = source.encoding
      source   = source.force_encoding(Encoding::UTF_8)

      hd = formatter.format lexer.lex(source)
      hd.force_encoding encoding
    end

    # Prints lines with a + or - symbol depending on the action
    def print_lines(hunk)
      lines = []
      lines << hunk.header

      hunk.each_line do |line|
        lines << print_line(line)
      end
      lines
    end

    # Prints lines with a + or - symbol depending on the action

    def print_line(line)
      if line.context?
        "  #{line.content}"
      elsif line.deletion?
        "- #{line.content}"
      elsif line.addition?
        "+ #{line.content}"
      end
    end

    # Highlights blob source
    #
    # @param [Rugged::Blob] blob to highlight source
    #
    # @return [String] highlighted HTML.code
    def highlight_source(source, filename = '')
      source    = source.force_encoding(Encoding::UTF_8)
      formatter = Rouge::Formatters::HTML.new(line_numbers: true, wrap: false)
      lexer     = Rouge::Lexer.guess_by_filename(filename)
      plain_text = Rouge::Lexers::PlainText

      if lexer == plain_text
        lexer = Rouge::Lexer.guess_by_source(source) || plain_text
      end

      formatter.format lexer.lex(source)
    end

    # Formats the text to remove multiple spaces and newlines, and then inserts
    # HTML linebreaks.
    #
    # Borrowed from Rails: ActionView::Helpers::TextHelper#simple_format
    # and simplified to just use <p> tags without any options, then modified
    # more later.
    #
    # @param [String] text the text you want formatted
    #
    # @return [String] the formatted text
    def simple_format(text)
      text.gsub!(/ +/, ' ')
      text.gsub!(/\r\n?/, "\n")
      text.gsub!(/\n/, "<br />\n")
      text
    end

    # Truncates a given text to a certain number of letters,
    # including a special ending if needed.
    #
    # the text to truncate
    # @param [String] text
    #
    # the length you want the output string
    # @option options [Integer] :length   (30)
    #
    # the string to show an omission.
    # @option options [String]  :omission ("...")
    #
    # @return [String] the truncated text.
    def truncate(text, options = {})
      options[:length] ||= 30
      options[:omission] ||= '...'

      if text
        l = options[:length] - options[:omission].length
        chars = text
        stop = separator(options, chars, l)
        parse_length(options, chars, text, stop)
      end
    end

    # Chooses a separator from options
    def separator(options, chars, l)
      if options[:separator]
        stop = chars.rindex(options[:separator], l) || l
      else
        stop = l
      end
      stop
    end

    # Parses length from options and applies it to the string
    def parse_length(options, chars, text, stop)
      if chars.length > options[:length]
        result = chars[0...stop] + options[:omission]
      else
        result = text
      end
      result.to_s
    end

    # Returns the rfc representation of a date, for use in the atom feeds.
    #
    # @param [DateTime] datetime the date to format
    # @return [String] the formatted datetime
    def rfc_date(datetime)
      datetime.strftime('%Y-%m-%dT%H:%M:%SZ') # 2003-12-13T18:30:02Z
    end

    # Returns the Hostname of the given install, for use in the atom feeds.
    #
    # @return [String] the hostname of the server.
    # Respects HTTP-X-Forwarded-For
    def hostname
      if request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/
        request.env['HTTP_X_FORWARDED_SERVER']
      else
        request.env['HTTP_HOST']
      end
    end
  end
end
