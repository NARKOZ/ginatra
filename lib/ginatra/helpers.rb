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
      partial(:actor_box, :locals => {:actor => actor, :role => role, :date => date})
    end

    def actor_boxes(commit)
      if commit.author.name == commit.committer.name
        actor_box(commit.committer, :committer, commit.committed_date)
      else
        actor_box(commit.author, :author, commit.authored_date) + actor_box(commit.committer, :committer, commit.committed_date)
      end
    end

    # The only reason this doesn't work 100% of the time is because grit doesn't :/
    # if i find a fix, it'll go upstream :D
    def file_listing(commit)
      out = commit.diffs.map do |diff|
        if diff.deleted_file
          %(<li class='rm'>#{diff.a_path}</li>)
        else
          cla = diff.new_file ? "add" : "diff"
          %(<li class='#{cla}'>#{diff.a_path}</li>)
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
  end
  
end