require 'rubygems'
require 'sinatra/base'
require 'grit'
require 'coderay'

current_path = File.expand_path(File.dirname(__FILE__))

module Ginatra; end

# Loading in reverse because RepoList needs to be loaded before MultiRepoList
Dir.glob("#{current_path}/ginatra/*.rb").reverse.each { |f| require f }

require "#{current_path}/sinatra/partials"

# Written myself. i know, what the hell?!
module Ginatra

  class Error < StandardError; end
  class CommitsError < Error; end
  
  class InvalidCommit < Error
    def initialize(id)
      super("Could not find a commit with the id of #{id}")
    end
  end

  VERSION = "1.1.0"

  class App < Sinatra::Base

    configure do
      current_path = File.expand_path(File.dirname(__FILE__))
      Config.load!
      set :raise_errors, Proc.new { test? }
      set :show_exceptions, Proc.new { development? }
      set :dump_errors, true
      set :logging, Proc.new { !test? }
      set :static, true
      set :public, "#{current_path}/../public"
      set :views, "#{current_path}/../views"
    end

    helpers do
      include Helpers
      include ::Sinatra::Partials
    end

    error CommitsError do
      'No commits were returned for ' + request.uri
    end

    get '/' do
      erb :index
    end

    get '/:repo.atom' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits
      return "" if @commits.empty?
      etag(@commits.first.id)
      builder :atom, :layout => nil
    end

    get '/:repo' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits
      etag(@commits.first.id)
      erb :log
    end

    get '/:repo/:ref.atom' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      return "" if @commits.empty?
      etag(@commits.first.id)
      builder :atom, :layout => nil
    end

    get '/:repo/:ref' do
      params[:page] = 1
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      etag(@commits.first.id)
      erb :log
    end

    get '/:repo/commit/:commit.patch' do
      response['Content-Type'] = "text/plain"
      @repo = RepoList.find(params[:repo])
      @repo.git.format_patch({}, "--stdout", "-1", params[:commit])
    end

    get '/:repo/commit/:commit' do
      @repo = RepoList.find(params[:repo])
      @commit = @repo.commit(params[:commit]) # can also be a ref
      etag(@commit.id)
      erb(:commit)
    end

    get '/:repo/archive/:tree.tar.gz' do
      response['Content-Type'] = "application/x-tar-gz"
      @repo = RepoList.find(params[:repo])
      @repo.archive_tar_gz(params[:tree])
    end

    get '/:repo/tree/:tree' do
      @repo = RepoList.find(params[:repo])

      if (tag = @repo.git.method_missing('rev_parse', {}, '--verify', "#{params[:tree]}^{tree}")).empty?
        # we don't have a tree.
        not_found
      else
        etag(tag)
      end

      @tree = @repo.tree(params[:tree]) # can also be a ref (i think)
      @path = {}
      @path[:tree] = "/#{params[:repo]}/tree/#{params[:tree]}"
      @path[:blob] = "/#{params[:repo]}/blob/#{params[:tree]}"
      erb(:tree)
    end

    get '/:repo/tree/:tree/*' do # for when we specify a path
      @repo = RepoList.find(params[:repo])
      @tree = @repo.tree(params[:tree])/params[:splat].first # can also be a ref (i think)
      if @tree.is_a?(Grit::Blob)
        # we need @tree to be a tree. if it's a blob, send it to the blob page
        # this allows people to put in the remaining part of the path to the file, rather than endless clicks like you need in github
        redirect "/#{params[:repo]}/blob/#{params[:tree]}/#{params[:splat].first}"
      else
        etag(@tree.id)
        @path = {}
        @path[:tree] = "/#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
        @path[:blob] = "/#{params[:repo]}/blob/#{params[:tree]}/#{params[:splat].first}"
        erb(:tree)
      end
    end

    get '/:repo/blob/:blob' do
      @repo = RepoList.find(params[:repo])
      @blob = @repo.blob(params[:blob])
      etag(@blob.id)
      erb(:blob)
    end

    get '/:repo/blob/:tree/*' do
      @repo = RepoList.find(params[:repo])
      @blob = @repo.tree(params[:tree])/params[:splat].first
      if @blob.is_a?(Grit::Tree)
        # as above, we need @blob to be a blob. if it's a tree, send it to the tree page
        # this allows people to put in the remaining part of the path to the folder, rather than endless clicks like you need in github
        redirect "/#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
      else
        etag(@blob.id)
        extension = params[:splat].first.split(".").last
        @highlighter = case extension
          when 'js'
            'javascript'
          when 'css'
            'css'
        end

        @highlighter ||= 'ruby'

        erb(:blob)
      end
    end

    get '/:repo/:ref/:page' do
      pass unless params[:page] =~ /^(\d)+$/
      params[:page] = params[:page].to_i
      @repo = RepoList.find(params[:repo])
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
