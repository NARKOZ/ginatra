require "rubygems"
require "sinatra"
require "grit"
gem "coderay"
require "coderay"

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  set :git_dir, "#{File.dirname(__FILE__)}/repos"
  set :description, "View My Rusty Git Repositories"
  layout :layout
end

# stolen from rails
class Array
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
  end
end

# stolen from http://ozmm.org/posts/try.html
class Object
  ##
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
end

# stolen from http://github.com/cschneid/irclogger/blob/master/lib/partials.rb
module Sinatra
  module Partials
    def partial(template, *args)
      options = args.extract_options!
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
end

module Grit
  class Tree
    alias :find :/
  end
end

# Written myself. i know, what the hell?!
module Ginatra
  
  # Convenience class for me!
  class RepoList
    def initialize
      @repo_list = []
      Dir.entries(Sinatra::Application.git_dir).each do |e|
        unless e == '.' || e == '..'
          @repo_list << Ginatra::Repo.new(e.gsub(/\.git$/, ''))
        end
      end
      return @repo_list
    end
    def each
      @repo_list.each do |r|
        yield(r)
      end
    end
    def include?(object)
      @repo_list.each do |r|
        if r == object
          return true
        end
      end
      return false
    end
  end

  # Convenience class for me!
  class Repo
    attr_reader :name, :param, :description
    def initialize(path)
      @repo = Grit::Repo.new("#{Sinatra::Application.git_dir}/#{path}.git/")
      @name = path.capitalize
      @param = path
      @description = @repo.description
      return @repo
    end
    def commits(num=10)
      @repo.commits('master', num)
    end
    def find_commit(short_id)
      commits(10000).select{|item| item.id =~ /^#{Regexp.escape(short_id)}/ }.first
    end
    def find_commit_by_tree(short_id)
      commits(10000).select{|item| item.tree.id =~ /^#{Regexp.escape(short_id)}/ }.first
    end
  end

  # Actually useful stuff
  module Helpers
    def gravatar_url(email)
      require "digest/md5"
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
      out = "<ul class='commit-files'>"
      commit.diffs.each do |diff|
        if diff.new_file
          out += "<li class=\"add\">#{diff.b_path}</li>"
        elsif diff.deleted_file
          out += "<li class=\"rm\">#{diff.a_path}</li>"
        else
          out += "<li class=\"diff\">#{diff.b_path}</li>"
        end
      end
      out += "</ul>"
      return out
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
