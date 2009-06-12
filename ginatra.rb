require "rubygems"
require "sinatra"
require "grit"
gem "coderay"
require "coderay"

configure do
  set :git_dir, "./repos"
  set :description, "View My Rusty Git Repositories"
  set :git_dirs, ["./repos/*.git"]
  set :ignored_files, ['.', '..', 'README.md']
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

  class Error < StandardError; end
  class CommitsError < Error; end

  # Convenience class for me!
  class RepoList

    def initialize
      @repo_list = Dir.entries(Sinatra::Application.git_dir).
                   delete_if{|e| Sinatra::Application.ignored_files.include? e }.
                   map!{|e| File.expand_path(e, Sinatra::Application.git_dir) }.
                   map!{|e| Repo.new(e) }
    end

    def find(local_param)
      @repo_list.find{|r| r.param == local_param }
    end

    def method_missing(sym, *args, &block)
      @repo_list.send(sym, *args, &block)
    end
  end

  class MultiRepoList < RepoList
    def initialize
      @repo_list = []
      Sinatra::Application.git_dirs.each do |git_dir|
        @repo_list << Dir.glob(git_dir).
                          delete_if{|e| Sinatra::Application.ignored_files.include? e }.
                          map{|e| File.expand_path(e) }
      end
      @repo_list.flatten!
      @repo_list.map!{|e| MultiRepo.new(e) }
    end
  end

  # Convenience class for me!
  class Repo

    attr_reader :name, :param, :description

    def initialize(path)
      @repo = Grit::Repo.new(path)
      @param = File.split(path).last.gsub(/\.git$/, '')
      @name = @param.capitalize
      @description = "Please edit the #{@param}.git/description file for this repository and set the description for it." if /^Unnamed repository;/.match(@repo.description)
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

    def method_missing(sym, *args, &block)
      @repo.send(sym, *args, &block)
    end
  end

  class MultiRepo < Repo

    attr_reader :name, :param, :description

    def self.create!(param)
      @repo_list = MultiRepoList.new
      @repo = @repo_list.find{|r| r.param =~ /^#{Regexp.escape param }$/}
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

error Ginatra::CommitsError do
  'No commits were returned for ' + request.uri
end

before do
  @repo_list ||= Ginatra::RepoList.new
end

get '/' do
  erb :index
end

get '/:repo' do
  @repo = @repo_list.find(params[:repo])
  @commits = @repo.commits
  raise Ginatra::CommitsError if @commits.empty?
  erb :log
end

get '/:repo/commit/:commit' do
  @repo = @repo_list.find(params[:repo])
  @commit = @repo.find_commit(params[:commit])
  erb :commit
end

get '/:repo/tree/:tree' do
  @repo = @repo_list.find(params[:repo])
  @commit = @repo.find_commit_by_tree(params[:tree])
  @tree = @commit.tree
  erb :tree
end
