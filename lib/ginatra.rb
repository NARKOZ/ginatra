require 'rubygems'
require 'sinatra/base'
require 'sinatra/cache'
require 'grit'

current_path = File.expand_path(File.dirname(__FILE__))

module Ginatra; end

require "#{current_path}/grit/commit"
require "#{current_path}/ginatra/config"
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

    register Sinatra::Cache

    configure do
      current_path = File.expand_path(File.dirname(__FILE__))
      Config.load!
      Config.each_pair do |k, v|
        set k, v
      end
      set :raise_errors, Proc.new { test? }
      set :show_exceptions, Proc.new { development? }
      set :dump_errors, true
      set :logging, Proc.new { !test? }
      set :static, true
      set :public, "#{current_path}/../public"
      set :views, "#{current_path}/../views"
      set :cache_enabled, true
      set :cache_page_extension, '.html'
      set :cache_output_dir, ''
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

    get '/:repo.atom' do
      @repo = @repo_list.find(params[:repo])
      @commits = @repo.commits
      return "" if @commits.empty?
      builder :atom, :layout => nil
    end

    get '/:repo' do
      @repo = @repo_list.find(params[:repo])
      @commits = @repo.commits
      erb :log
    end

    get '/:repo/:ref.atom' do
      @repo = @repo_list.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      return "" if @commits.empty?
      builder :atom, :layout => nil
    end

    get '/:repo/:ref' do
      params[:page] = 1
      @repo = @repo_list.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      erb :log
    end

    get '/:repo/commit/:commit.patch' do
      response['Content-Type'] = "text/plain"
      @repo = @repo_list.find(params[:repo])
      @repo.git.format_patch({}, "--stdout", "-1", params[:commit])
    end

    get '/:repo/commit/:commit' do
      @repo = @repo_list.find(params[:repo])
      @commit = @repo.commit(params[:commit]) # can also be a ref
      cache erb(:commit)
    end

    get '/:repo/archive/:tree.tar.gz' do
      response['Content-Type'] = "application/x-tar-gz"
      @repo = @repo_list.find(params[:repo])
      @repo.archive_tar_gz(params[:tree])
    end

    get '/:repo/tree/:tree' do
      @repo = @repo_list.find(params[:repo])
      @tree = @repo.tree(params[:tree]) # can also be a ref (i think)
      @path = {}
      @path[:tree] = "/#{params[:repo]}/tree/#{params[:tree]}"
      @path[:blob] = "/#{params[:repo]}/blob/#{params[:tree]}"
      cache erb(:tree)
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
        cache erb(:tree)
      end
    end

    get '/:repo/blob/:blob' do
      @repo = @repo_list.find(params[:repo])
      @blob = @repo.blob(params[:blob])
      cache erb(:blob)
    end

    get '/:repo/blob/:tree/*' do
      @repo = @repo_list.find(params[:repo])
      @blob = @repo.tree(params[:tree])/params[:splat].first
      if @blob.is_a?(Grit::Tree)
        # as above, we need @blob to be a blob. if it's a tree, send it to the tree page
        # this allows people to put in the remaining part of the path to the folder, rather than endless clicks like you need in github
        redirect "/#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
      else
        cache erb(:blob)
      end
    end

    get '/:repo/:ref/:page' do
      pass unless params[:page] =~ /^(\d)+$/
      params[:page] = params[:page].to_i
      @repo = @repo_list.find(params[:repo])
      @commits = @repo.commits(params[:ref], 10, (params[:page] - 1) * 10)
      @next_commits = !@repo.commits(params[:ref], 10, params[:page] * 10).empty?
      if params[:page] - 1 > 0 
        @previous_commits = !@repo.commits(params[:ref], 10, (params[:page] - 1) * 10).empty?
      end
      @separator = @next_commits && @previous_commits
      erb :log
    end

  end # App

end # Ginatra
