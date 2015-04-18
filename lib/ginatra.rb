require 'roda'
require 'rouge'
require 'ginatra/config'
require 'ginatra/errors'
require 'ginatra/helpers'
require 'ginatra/repo'
require 'ginatra/repo_list'
require 'ginatra/repo_stats'

module Ginatra
  # The main application class.
  # Contains all the core application logic and mounted in +config.ru+ file.
  class App < Roda
    include Helpers

    use Rack::Static, :urls=>%w'/css /favicon.ico /img /js', :root=>'public'

    plugin :render, :views=>File.join(File.dirname(File.dirname(File.expand_path(__FILE__))), 'views')
    plugin :environments
    plugin :symbol_views
    plugin :symbol_matchers
    plugin :path_matchers
    plugin :sinatra_helpers
    plugin :delegate
    request_delegate :get, :root, :on, :is

    configure :development do
      # Use better errors in development
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = File.dirname(File.dirname(File.expand_path(__FILE__)))

      # Reload modified files in development
      # require 'sinatra/reloader'
      # register Sinatra::Reloader
      # Dir["#{settings.root}/ginatra/*.rb"].each { |file| also_reload file }
    end

    def cache(obj)
      etag obj if self.class.production?
    end

    def partial(template, opts={})
      render("_#{template}", opts)
    end

    plugin :not_found do
      render '404'
    end

    plugin :error_handler do |e|
      case e
      when Ginatra::RepoNotFound, Ginatra::InvalidRef, Rugged::OdbError, Rugged::ObjectError, Rugged::InvalidError
        response.status = 404
        render '404'
      else
        raise e unless self.class.production?
        render '500'
      end
    end

    route do 
      get do
        # The root route
        root do
          @repositories = Ginatra::RepoList.list
          :index
        end

        # The atom feed of recent commits to a +repo+.
        #
        # This only returns commits to the +master+ branch.
        #
        # @param [String] repo the repository url-sanitised-name
        is :extension => 'atom' do |repo|
          @repo = RepoList.find(repo)
          @commits = @repo.commits

          if @commits.empty?
            return ''
          else
            cache "#{@commits.first.oid}/atom"
            content_type 'application/xml'
            render :atom
          end
        end

        # @param [String] repo the repository url-sanitised-name
        on :repo do |repo|
          @repo = RepoList.find(repo)

          # The html page for a +repo+.
          #
          # Shows the most recent commits in a log format.
          is ['', true] do
            if @repo.branches.none?
              :empty_repo
            else
              @page = 1
              @ref = @repo.branch_exists?('master') ? 'master' : @repo.branches.first.name
              @commits = @repo.commits(@ref)
              cache "#{@commits.first.oid}/log"
              @next_commits = !@repo.commits(@ref, 10, 10).nil?
              :log
            end
          end

          # The atom feed of recent commits to a certain branch of a +repo+.
          #
          # @param [String] ref the repository ref
          is :extension => 'atom' do |ref|
            @commits = @repo.commits(ref)

            if @commits.empty?
              return ''
            else
              cache "#{@commits.first.oid}/atom/ref"
              content_type 'application/xml'
              render :atom
            end
          end

          # The html page for a given +ref+ of a +repo+.
          #
          # Shows the most recent commits in a log format.
          #
          # @param [String] ref the repository ref
          is :ref do |ref|
            @ref = ref
            @commits = @repo.commits(ref)
            cache "#{@commits.first.oid}/ref" if @commits.any?
            @page = 1
            @next_commits = !@repo.commits(ref, 10, 10).nil?
            :log
          end

          # The html page for a +repo+ stats.
          #
          # Shows information about repository branch.
          #
          # @param [String] ref the repository ref
          is 'stats/:ref' do |ref|
            @stats = RepoStats.new(@repo, ref)
            :stats
          end

          on 'commit' do
            # The patch file for a given commit to a +repo+.
            #
            # @param [String] commit the repository commit
            is :extension=>'patch' do |commit|
              content_type 'text/plain'
              commit = @repo.commit(commit)
              cache "#{commit.oid}/patch"
              diff   = commit.parents.first.diff(commit)
              diff.patch
            end

            # The html representation of a commit.
            #
            # @param [String] commit the repository commit
            is :commit do |commit|
              @commit = @repo.commit(commit)
              cache @commit.oid
              :commit
            end
          end

          # The html representation of a tag.
          #
          # @param [String] tag the repository tag
          is 'tag/:tag' do |tag|
            @commit = @repo.commit_by_tag(tag)
            cache "#{@commit.oid}/tag"
            :commit
          end

          # @param [String] tree the repository tree
          on 'tree/:tree' do |tree|
            @_tree = tree
            @tree = @repo.find_tree(tree)

            # HTML page for a given tree in a given +repo+
            is do
              cache @tree.oid

              @path = {
                blob: "#{repo}/blob/#{tree}",
                tree: "#{repo}/tree/#{tree}"
              }
              is_pjax? ? render(:tree) : :tree
            end

            # HTML page for a given tree in a given +repo+.
            #
            # This one supports a splat parameter so you can specify a path.
            is :rest do |rest|
              @rest = rest
              cache "#{@tree.oid}/#{rest}"

              @tree.walk(:postorder) do |root, entry|
                @tree = @repo.lookup entry[:oid] if "#{root}#{entry[:name]}" == rest
              end

              @path = {
                blob: "#{repo}/blob/#{tree}/#{rest}",
                tree: "#{repo}/tree/#{tree}/#{rest}"
              }
              is_pjax? ? render(:tree) : :tree
            end
          end

          on 'blob/:tree' do |tree|
            @_tree = tree
            @tree = @repo.find_tree(tree)

            # HTML page for a given blob in a given +repo+
            is do
              cache @blob[:oid]
              view :blob, layout: !is_pjax?
            end

            # HTML page for a given blob in a given repo.
            #
            # Uses a splat param to specify a blob path.
            is :rest do |rest|
              @rest = rest
              @tree.walk(:postorder) do |root, entry|
                @blob = entry if "#{root}#{entry[:name]}" == rest
              end

              cache "#{@blob[:oid]}/#{@tree.oid}"
              is_pjax? ? render(:blob) : :blob
            end
            
          end

          # HTML page for a raw blob contents in a given repo.
          #
          # Uses a splat param to specify a blob path.
          is 'raw/:tree/:rest' do |tree, rest|
            @rest = rest
            @tree = @repo.find_tree(tree)

            @tree.walk(:postorder) do |root, entry|
              @blob = entry if "#{root}#{entry[:name]}" == rest
            end

            cache "#{@blob[:oid]}/#{@tree.oid}/raw"
            blob = @repo.find_blob @blob[:oid]
            if blob.binary?
              content_type 'application/octet-stream'
            else
              content_type 'text/plain'
            end
            blob.text
          end

          # Pagination route for the commits to a given ref in a +repo+.
          is ':ref/page/:page' do |ref, page|
            @ref = ref
            next unless page =~ /\A\d+\z/
            @page = page = page.to_i
            @commits = @repo.commits(ref, 10, (page - 1) * 10)
            cache "#{@commits.first.oid}/page/#{page}/ref/#{ref}" if @commits.any?
            @next_commits = !@repo.commits(ref, 10, page * 10).nil?
            if page - 1 > 0
              @previous_commits = !@repo.commits(ref, 10, (page - 1) * 10).empty?
            end
            :log
          end
        end # :repo
      end # get
    end # route
  end # App
end # Ginatra
