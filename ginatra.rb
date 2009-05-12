require "rubygems"
require "sinatra/lib/sinatra"
require "grit"
gem "coderay"
require "coderay"

configure do
  set :git_dir, "#{File.dirname(__FILE__)}/repos"
  set :description, "View My Rusty Git Repositories"
end

# stolen from http://github.com/cschneid/irclogger/blob/master/lib/partials.rb
module Sinatra::Partials
  def partial(template, *args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.merge!(:layout => false)
    if collection = options.delete(:collection) then
      collection.inject([]) do |buffer, member|
        buffer << erb(template, options.merge(:layout =>
        false, :locals => {template.to_sym => member}))
      end.join("\n")
    else
      erb(:"_#{template}", options)
    end
  end
end

class Grit::Tree
  alias :find :/
end

# Written myself. i know, what the hell?!
module Ginatra

  # Convenience class for me!
  class RepoList
    
    # Files not to include in the repository list
    IGNORED_FILES = ['.', '..', 'README.md']

    def initialize
      @repo_list = Dir.entries(Sinatra::Application.git_dir)
      @repo_list.delete_if{|e| IGNORED_FILES.include? e }
      @repo_list.map!{|e| Ginatra::Repo.new(e.gsub(/\.git$/, ''))} 
    end

    def each(*a, &b)
      @repo_list.each *a, &b
    end

    def include?(*a, &b)
      @repo_list.include? *a, &b
    end
  end

  # Convenience class for me!
  class Repo

    attr_reader :name, :param, :description

    def initialize(path)
      @repo = Grit::Repo.new("#{Sinatra::Application.git_dir}/#{path}.git/")
      @name = path.capitalize
      @param = path
      @description = "Please edit the .git/description file for this repository and set the description for it." if /^Unnamed repository;/.match(@repo.description)
      @repo
    end

    def commits(num=10)
      @repo.commits('master', num)
    end

    def find_commit(short_id)
      commits(10000).find{|item| item.id =~ /^#{Regexp.escape(short_id)}/ }
    end

    def find_commit_by_tree(short_id)
      commits(10000).find{|item| item.tree.id =~ /^#{Regexp.escape(short_id)}/ }
    end
  end

  # Actually useful stuff
  module Helpers
    require "digest/md5"

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

    def diff_highlight(text)
      CodeRay.scan(text, :diff).html
    end
  end

end

helpers do
  include Ginatra::Helpers
  include Sinatra::Partials
end

get '/' do
  @repo_list = Ginatra::RepoList.new
  erb :index
end

get '/:repo' do
  @repo = Ginatra::Repo.new(params[:repo])
  erb :log
end

get '/:repo/commit/:commit' do
  @repo = Ginatra::Repo.new(params[:repo])
  @commit = @repo.find_commit(params[:commit])
  erb :commit
end

get '/:repo/tree/:tree' do
  @repo = Ginatra::Repo.new(params[:repo])
  @commit = @repo.find_commit_by_tree(params[:tree])
  @tree = @commit.tree
  erb :tree
end
