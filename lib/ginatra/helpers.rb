require "digest/md5"

module Ginatra
  # Actually useful stuff
  module Helpers

    def gravatar_url(email)
      "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=40"
    end

    def nicetime(date)
      date.strftime("%b %d, %Y &ndash; %H:%M")
    end

    def actor_box(actor, role, date)
      partial(:actor_box, :locals => { :actor => actor, :role => role, :date => date })
    end

    def actor_boxes(commit)
      if commit.author.name == commit.committer.name
        actor_box(commit.committer, :committer, commit.committed_date)
      else
        actor_box(commit.author, :author, commit.authored_date) + actor_box(commit.committer, :committer, commit.committed_date)
      end
    end

    def commit_ref(ref, repo_param)
      ref_class = case ref.class
                  when Grit::Tag
                    "tag"
                  when Grit::Head
                    "head"
                  when Grit::Remote
                    "remote"
                  else
                    ""
                  end
      "<a class=\"ref #{ref_class}\" href=\"/#{repo_param}/#{ref.name}\">#{ref.name}</a>"
    end

    def commit_refs(commit, repo_param)
      commit.refs.map{ |r| commit_ref(r, repo_param) }.join("\n")
    end

    def archive_link(tree, repo_param)
      "<a class=\"download\" href=\"/#{repo_param}/archive/#{tree.id}.tar.gz\" title=\"Download a tar.gz snapshot of this Tree\">Download Archive</a>"
    end

    def patch_link(commit, repo_param)
      "<a class=\"download\" href=\"/#{repo_param}/commit/#{commit.id}.patch\" title=\"Download a patch file of this Commit\">Download Patch</a>"
    end

    # The only reason this doesn't work 100% of the time is because grit doesn't :/
    # if i find a fix, it'll go upstream :D
    def file_listing(commit)
      count = 0
      out = commit.diffs.map do |diff|
        count = count + 1
        if diff.deleted_file
          %(<li class='rm'><a href='#file_#{count}'>#{diff.a_path}</a></li>)
        else
          cla = diff.new_file ? "add" : "diff"
          %(<li class='#{cla}'><a href='#file_#{count}'>#{diff.a_path}</a></li>)
        end
      end
      "<ul class='commit-files'>#{out.join}</ul>"
    end

    # Stolen from rails: ActionView::Helpers::TextHelper#simple_format
    #   and simplified to just use <p> tags without any options
    # modified since
    def simple_format(text)
      text.gsub!(/ +/, " ")
      text.gsub!(/\r\n?/, "\n")
      text.gsub!(/\n/, "<br />\n")
      text
    end

    # stolen from rails: ERB::Util
    def html_escape(s)
      s.to_s.gsub(/[&"<>]/) do |special|
        { '&' => '&amp;',
          '>' => '&gt;',
          '<' => '&lt;',
          '"' => '&quot;' }[special]
      end
    end
    alias :h :html_escape

    # Stolen and bastardised from rails
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

    # stolen from Marley
    def rfc_date(datetime)
      datetime.strftime("%Y-%m-%dT%H:%M:%SZ") # 2003-12-13T18:30:02Z
    end

    # stolen from Marley
    def hostname
      (request.env['HTTP_X_FORWARDED_SERVER'] =~ /[a-z]*/) ? request.env['HTTP_X_FORWARDED_SERVER'] : request.env['HTTP_HOST']
    end

    def atom_feed_link(repo_param, ref=nil)
      "<a href=\"/#{repo_param}#{"/#{ref}" if !ref.nil?}.atom\" title=\"Atom Feed\" class=\"atom\">Feed</a>"
    end

  end
end