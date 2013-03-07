require 'sinatra/base'
require 'sinatra/partials'
require 'json'
require 'rouge'
require 'ginatra/config'
require 'ginatra/errors'
require 'ginatra/helpers'
require 'ginatra/repo'
require 'ginatra/repo_list'
require 'ginatra/graph_commit'

module Ginatra
  # The main application class.
  #
  # This class contains all the core application logic
  # and is what is mounted by the +rackup.ru+ files.
  class App < Sinatra::Base
    helpers Helpers, Sinatra::Partials

    configure do
      Config.load!
      set :host, Ginatra::Config.host
      set :port, Ginatra::Config.port
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

    # Let's handle a CommitsError.
    #
    # @todo prettify
    error CommitsError do
      'No commits were returned for ' + request.uri
    end

    # The root route
    # This works by interacting with the Ginatra::Repolist singleton.
    get '/' do
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
      return "" if @commits.empty?
      etag(@commits.first.id) if Ginatra::App.production?
      builder :atom, :layout => nil
    end

    # The html page for a +repo+.
    #
    # Shows the most recent commits in a log format
    #
    # @param [String] repo the repository url-sanitised-name
    get '/:repo' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits
      params[:page] = 1
      params[:ref]  = @repo.get_head('master').nil? ? @repo.heads.first.name : 'master'
      @next_commits = @repo.commits(params[:ref], 10, 10).any?
      etag(@commits.first.id) if Ginatra::App.production?
      erb :log
    end

    get '/:repo/graph' do
      @repo = RepoList.find(params[:repo])
      max_count = params[:max_count].nil? ? 650 : params[:max_count].to_i
      commits = @repo.all_commits(max_count)

      days = GraphCommit.index_commits(commits)
      @days_json = days.compact.collect {|d| [d.day, d.strftime('%b')] }.to_json
      @commits_json = commits.collect do |c|
        h = {}
        h[:parents] = c.parents.collect {|p| [p.id, 0, 0] }
        h[:author]  = c.author.name.force_encoding('UTF-8')
        h[:time]    = c.time
        h[:space]   = c.space
        h[:refs]    = c.refs.collect {|r| r.name }.join(' ') unless c.refs.nil?
        h[:id]      = c.sha
        h[:date]    = c.date
        h[:message] = c.message.force_encoding('UTF-8')
        h[:login]   = c.author.email
        h
      end.to_json
      erb :graph
    end

    # The atom feed of recent commits to a certain branch of a +repo+.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] ref the repository ref
    get '/:repo/:ref.atom' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      return "" if @commits.empty?
      etag(@commits.first.id) if Ginatra::App.production?
      builder :atom, :layout => nil
    end

    # The html page for a given +ref+ of a +repo+.
    #
    # Shows the most recent commits in a log format
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] ref the repository ref
    get '/:repo/:ref' do
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref])
      params[:page] = 1
      @next_commits = @repo.commits(params[:ref], 10, 10).any?
      etag(@commits.first.id) if Ginatra::App.production?
      erb :log
    end

    # The patch file for a given commit to a +repo+.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] commit the repository commit
    get '/:repo/commit/:commit.patch' do
      content_type :txt
      @repo = RepoList.find(params[:repo])
      @repo.git.format_patch({}, "--stdout", "-1", params[:commit])
    end

    # The html representation of a commit.
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] commit the repository commit
    get '/:repo/commit/:commit' do
      @repo = RepoList.find(params[:repo])
      @commit = @repo.commit(params[:commit]) # can also be a ref
      etag(@commit.id) if Ginatra::App.production?
      erb :commit
    end

    # Download an archive of a given tree!
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/archive/:tree.tar.gz' do
      content_type :gz
      @repo = RepoList.find(params[:repo])
      @repo.archive_tar_gz(params[:tree])
    end

    # HTML page for a given tree in a given +repo+
    #
    # @todo cleanup!
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/tree/:tree' do
      @repo = RepoList.find(params[:repo])

      if (tag = @repo.git.rev_parse({'--verify' => ''}, "#{params[:tree]}^{tree}")).empty?
        # we don't have a tree.
        not_found
      else
        etag(tag) if Ginatra::App.production?
      end

      @tree = @repo.tree(params[:tree]) # can also be a ref (i think)
      @path = {}
      @path[:tree] = "#{params[:repo]}/tree/#{params[:tree]}"
      @path[:blob] = "#{params[:repo]}/blob/#{params[:tree]}"
      erb :tree, :layout => !is_pjax?
    end

    # HTML page for a given tree in a given +repo+.
    #
    # This one supports a splat parameter so you can specify a path
    #
    # @todo cleanup!
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/tree/:tree/*' do # for when we specify a path
      @repo = RepoList.find(params[:repo])
      @tree = @repo.tree(params[:tree])/params[:splat].first # can also be a ref (i think)
      if @tree.is_a?(Grit::Blob)
        # we need @tree to be a tree. if it's a blob, send it to the blob page
        # this allows people to put in the remaining part of the path to the file, rather than endless clicks like you need in github
        redirect "#{params[:repo]}/blob/#{params[:tree]}/#{params[:splat].first}"
      else
        etag(@tree.id) if Ginatra::App.production?
        @path = {}
        @path[:tree] = "#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
        @path[:blob] = "#{params[:repo]}/blob/#{params[:tree]}/#{params[:splat].first}"
        erb :tree, :layout => !is_pjax?
      end
    end

    # HTML page for a given blob in a given +repo+
    #
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/blob/:blob' do
      @repo = RepoList.find(params[:repo])
      @blob = @repo.blob(params[:blob])
      etag(@blob.id) if Ginatra::App.production?
      erb :blob, :layout => !is_pjax?
    end

    # HTML page for a given blob in a given repo.
    #
    # Uses a splat param to specify a blob path.
    #
    # @todo cleanup!
    # @param [String] repo the repository url-sanitised-name
    # @param [String] tree the repository tree
    get '/:repo/blob/:tree/*' do
      @repo = RepoList.find(params[:repo])
      @blob = @repo.tree(params[:tree])/params[:splat].first
      if @blob.is_a?(Grit::Tree)
        # as above, we need @blob to be a blob. if it's a tree, send it to the tree page
        # this allows people to put in the remaining part of the path to the folder, rather than endless clicks like you need in github
        redirect "/#{params[:repo]}/tree/#{params[:tree]}/#{params[:splat].first}"
      else
        etag(@blob.id) if Ginatra::App.production?
        erb :blob, :layout => !is_pjax?
      end
    end

    # pagination route for the commits to a given ref in a +repo+.
    #
    # @todo cleanup!
    # @param [String] repo the repository url-sanitised-name
    # @param [String] ref the repository ref
    get '/:repo/:ref/page/:page' do
      pass unless params[:page] =~ /\A\d+\z/
      params[:page] = params[:page].to_i
      @repo = RepoList.find(params[:repo])
      @commits = @repo.commits(params[:ref], 10, (params[:page] - 1) * 10)
      @next_commits = !@repo.commits(params[:ref], 10, params[:page] * 10).empty?
      if params[:page] - 1 > 0
        @previous_commits = !@repo.commits(params[:ref], 10, (params[:page] - 1) * 10).empty?
      end
      erb :log
    end

  end # App

end # Ginatra
