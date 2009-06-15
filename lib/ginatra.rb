require 'rubygems'
require 'sinatra/base'
require 'grit'

current_path = File.expand_path(File.dirname(__FILE__))

module Ginatra; end

require "#{current_path}/ginatra/helpers"
require "#{current_path}/ginatra/repo"
require "#{current_path}/ginatra/repo_list"
require "#{current_path}/sinatra/partials"

# Written myself. i know, what the hell?!
module Ginatra

  class Error < StandardError; end
  class CommitsError < Error; end
  
  VERSION = "0.9.9"
  
  class App < Sinatra::Base

    configure do
      set :git_dir, "./repos"
      set :description, "View My Rusty Git Repositories"
      set :git_dirs, ["./repos/*.git"]
      set :ignored_files, ['.', '..', 'README.md']
      set :raise_errors, Proc.new { test? }
      set :show_exceptions, Proc.new { development? }
      set :dump_errors, true
      set :logging, Proc.new { ! test? }
      set :static, true
      set :public, 'public'
    end

    helpers do
      include Helpers
      include ::Sinatra::Partials
    end

    error CommitsError do
      'No commits were returned for ' + request.uri
    end

    before do
      @repo_list ||= RepoList.new
    end

    get '/' do
      erb :index
    end

    get '/:repo' do
      @repo = @repo_list.find(params[:repo])
      @commits = @repo.commits
      erb :log
    end

    get '/:repo/:ref' do
      @repo = @repo_list.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      erb :log
    end

    get '/:repo/commit/:commit' do
      @repo = @repo_list.find(params[:repo])
      @commit = @repo.commit(params[:commit]) # can also be a ref
      erb :commit
    end

    get '/:repo/tree/:tree' do
      @repo = @repo_list.find(params[:repo])
      @tree = @repo.tree(params[:tree]) # can also be a ref (i think)
      @path = {}
      @path[:tree] = "/#{params[:repo]}/tree/#{params[:tree]}"
      @path[:blob] = "/#{params[:repo]}/blob/#{params[:tree]}"
      erb :tree
    end

    get '/:repo/tree/:tree/*' do # for when we specify a path
      @repo = @repo_list.find(params[:repo])
      @tree = @repo.tree(params[:tree])/params[:splat].first # can also be a ref (i think)
      if @tree.is_a?(Grit::Blob)
        # we need @tree to be a tree. if it's a blob, send it to the blob page
        # this allows people to put in the remaining part of the path to the file, rather than endless clicks like you need in github
        redirect "/#{params[:repo]}/blob/#{params[:tree]}/#{params[:splat].first}"
      else
        @path = {}
        @path[:tree] = "/#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
        @path[:blob] = "/#{params[:repo]}/blob/#{params[:tree]}/#{params[:splat].first}"
        erb :tree
      end
    end

    get '/:repo/blob/:blob' do
      @repo = @repo_list.find(params[:repo])
      @blob = @repo.blob(params[:blob])
      erb :blob
    end

    get '/:repo/blob/:tree/*' do
      @repo = @repo_list.find(params[:repo])
      @blob = @repo.tree(params[:tree])/params[:splat].first
      if @blob.is_a?(Grit::Tree)
        # as above, we need @blob to be a blob. if it's a tree, send it to the tree page
        # this allows people to put in the remaining part of the path to the folder, rather than endless clicks like you need in github
        redirect "/#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
      else
        erb :blob
      end
    end
  end # App

end # Ginatra
