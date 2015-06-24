require 'sinatra/base'
require 'sinatra/partials'
require 'rouge'
require 'ginatra/config'
require 'ginatra/errors'
require 'ginatra/logger'
require 'ginatra/helpers'
require 'ginatra/repo'
require 'ginatra/repo_list'
require 'ginatra/repo_stats'

module Ginatra
  # The main application class.
  # Contains all the core application logic and mounted in +config.ru+ file.
  class App < Sinatra::Base
    include Logger
    helpers Helpers, Sinatra::Partials

    configure do
      set :host, Ginatra.config.host
      set :port, Ginatra.config.port
      set :public_folder, "#{settings.root}/../public"
      set :views, "#{settings.root}/../views"
      enable :dump_errors, :logging, :static
    end

    configure :development do
      # Use better errors in development
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = settings.root

      # Reload modified files in development
      require 'sinatra/reloader'
      register Sinatra::Reloader
      Dir["#{settings.root}/ginatra/*.rb"].each { |file| also_reload file }
    end

    def cache(obj)
      etag obj if settings.production?
    end

    not_found do
      erb :'404', layout: false
    end

    error Ginatra::RepoNotFound, Ginatra::InvalidRef,
          Rugged::OdbError, Rugged::ObjectError, Rugged::InvalidError do
      halt 404, erb(:'404', layout: false)
    end

    error 500 do
      erb :'500', layout: false
    end

    # The root route
    get '/' do
      @repositories = Ginatra::RepoList.list
      erb :index
    end

    # The atom feed of recent commits to a +repo+.
    #
    # This only returns commits to the +master+ branch.
    #
    # @param [String] repo the repository url-sanitised-name
    get '/:repo.atom' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits

      if @commits.empty?
        return ''
      else
        cache "#{@commits.first.oid}/atom"
        content_type 'application/xml'
        erb :atom, layout: false
      end
    end

    # The html page for a +repo+.
    #
    # Shows the most recent commits in a log format.
    #
    # @param [String] repo the repository url-sanitised-name
    get '/:repo/?' do
      @repo = RepoList.find(params[:repo])

      if @repo.branches.none?
        erb :empty_repo
      else
        params[:page] = 1
        if @repo.branch_exists?('master')
          params[:ref] = 'master'
        else
          params[:ref] = @repo.branches.first.name
        end
        @commits = @repo.commits(params[:ref])
        cache "#{@commits.first.oid}/log"
        @next_commits = !@repo.commits(params[:ref], 10, 10).nil?
        erb :log
      end
    end

    # The atom feed of recent commits to a certain branch of a +repo+.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] ref the repository ref
    get '/:repo/:ref.atom' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref])

      if @commits.empty?
        return ''
      else
        cache "#{@commits.first.oid}/atom/ref"
        content_type 'application/xml'
        erb :atom, layout: false
      end
    end

    # The html page for a given +ref+ of a +repo+.
    #
    # Shows the most recent commits in a log format.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] ref the repository ref
    get '/:repo/:ref' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      cache "#{@commits.first.oid}/ref" if @commits.any?
      params[:page] = 1
      @next_commits = !@repo.commits(params[:ref], 10, 10).nil?
      erb :log
    end

    # The html page for a +repo+ stats.
    #
    # Shows information about repository branch.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] ref the repository ref
    get '/:repo/stats/:ref' do
      @repo = RepoList.find(params[:repo])
      @stats = RepoStats.new(@repo, params[:ref])
      erb :stats
    end

    # The patch file for a given commit to a +repo+.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] commit the repository commit
    get '/:repo/commit/:commit.patch' do
      content_type :txt
      repo   = RepoList.find(params[:repo])
      commit = repo.commit(params[:commit])
      cache "#{commit.oid}/patch"
      diff   = commit.parents.first.diff(commit)
      diff.patch
    end

    # The html representation of a commit.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] commit the repository commit
    get '/:repo/commit/:commit' do
      @repo = RepoList.find(params[:repo])
      @commit = @repo.commit(params[:commit])
      cache @commit.oid
      erb :commit
    end

    # The html representation of a tag.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tag the repository tag
    get '/:repo/tag/:tag' do
      @repo = RepoList.find(params[:repo])
      @commit = @repo.commit_by_tag(params[:tag])
      cache "#{@commit.oid}/tag"
      erb :commit
    end

    # HTML page for a given tree in a given +repo+
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/tree/:tree' do
      @repo = RepoList.find(params[:repo])
      @tree = @repo.find_tree(params[:tree])
      cache @tree.oid

      @path = {
        blob: "#{params[:repo]}/blob/#{params[:tree]}",
        tree: "#{params[:repo]}/tree/#{params[:tree]}"
      }
      erb :tree, layout: !pjax?
    end

    # HTML page for a given tree in a given +repo+.
    #
    # This one supports a splat parameter so you can specify a path.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/tree/:tree/*' do
      @repo = RepoList.find(params[:repo])
      @tree = @repo.find_tree(params[:tree])
      cache "#{@tree.oid}/#{params[:splat].first}"

      @tree.walk(:postorder) do |root, entry|
        @tree = @repo.lookup entry[:oid] if "#{root}#{entry[:name]}" == params[:splat].first
      end

      @path = {
        blob: "#{params[:repo]}/blob/#{params[:tree]}/#{params[:splat].first}",
        tree: "#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
      }
      erb :tree, layout: !pjax?
    end

    # HTML page for a given blob in a given +repo+
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/blob/:blob' do
      @repo = RepoList.find(params[:repo])
      @tree = @repo.lookup(params[:tree])

      @tree.walk(:postorder) do |root, entry|
        @blob = entry if "#{root}#{entry[:name]}" == params[:splat].first
      end

      cache @blob[:oid]
      erb :blob, layout: !pjax?
    end

    # HTML page for a given blob in a given repo.
    #
    # Uses a splat param to specify a blob path.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/blob/:tree/*' do
      @repo = RepoList.find(params[:repo])
      @tree = @repo.find_tree(params[:tree])

      @tree.walk(:postorder) do |root, entry|
        @blob = entry if "#{root}#{entry[:name]}" == params[:splat].first
      end

      cache "#{@blob[:oid]}/#{@tree.oid}"
      erb :blob, layout: !pjax?
    end

    # HTML page for a raw blob contents in a given repo.
    #
    # Uses a splat param to specify a blob path.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/raw/:tree/*' do
      @repo = RepoList.find(params[:repo])
      @tree = @repo.find_tree(params[:tree])

      @tree.walk(:postorder) do |root, entry|
        @blob = entry if "#{root}#{entry[:name]}" == params[:splat].first
      end

      cache "#{@blob[:oid]}/#{@tree.oid}/raw"
      blob = @repo.find_blob @blob[:oid]
      if blob.binary?
        content_type 'application/octet-stream'
        blob.text
      else
        content_type :txt
        blob.text
      end
    end

    # Pagination route for the commits to a given ref in a +repo+.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] ref the repository ref
    get '/:repo/:ref/page/:page' do
      pass unless params[:page] =~ /\A\d+\z/
      params[:page] = params[:page].to_i
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref], 10, (params[:page] - 1) * 10)
      cache "#{@commits.first.oid}/page/#{params[:page]}/ref/#{params[:ref]}" if @commits.any?
      @next_commits = !@repo.commits(params[:ref], 10, params[:page] * 10).nil?
      if params[:page] - 1 > 0
        @previous_commits = !@repo.commits(params[:ref], 10, (params[:page] - 1) * 10).empty?
      end
      erb :log
    end
  end # App
end # Ginatra
