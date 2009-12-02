require 'singleton'

module Ginatra
  # A singleton class that lets us make and use a constantly updating 
  # list of repositories.
  class RepoList
    include Singleton
    attr_accessor :list
    
    # This creates the list, then does the first refresh to 
    # populate it.
    #
    # It returns what refresh returns.
    def initialize
      self.list = []
      self.refresh
    end
    
    # The preferred way to access the list publicly. 
    # 
    # @return [Array<Ginatra::Repo>] a list of ginatra repos.
    def self.list
      self.instance.refresh
      self.instance.list
    end

    # searches through the configured directory globs to find all the repositories
    # and adds them if they're not already there.
    #
    # @todo Docs: what the hell does this return?
    def refresh
      Ginatra::Config.git_dirs.map! do |git_dir|
        files = Dir.glob(git_dir)
        files.each { |e| add(e) unless Ginatra::Config.ignored_files.include?(File.split(e).last) }
      end
    end

    # adds a Repo corresponding to the path it found a git repo at in the configured
    # globs. Checks to see that it's not there first
    #
    # @param [String] path the path of the git repo
    # @param [String] param the param of the repo if it differs, 
    #   for looking to see if it's already on the list
    #
    # @todo Docs: what does this return?
    def add(path, param = File.split(path).last)
      unless self.has_repo?(param)
        list << Repo.new(path)
      end
    end

    # checks to see if the list contains a repo with a param 
    # matching the one passed in.
    #
    # @param [String] local_param param to check.
    #
    # @return [true, false]
    def has_repo?(local_param)
      !list.find { |r| r.param == local_param }.nil?
    end

    # quick way to look up if there is a repo with a given param in the list. 
    # If not, it refreshes the list and tries again.
    #
    # @param [String] local_param the param to lookup
    #
    # @return [Ginatra::Repo] the repository corresponding to that param.
    def find(local_param)
      if repo = list.find { |r| r.param == local_param }
        repo
      else
        refresh
        list.find { |r| r.param == local_param }
      end
    end

    # This just brings up the find method to the class scope.
    #
    # @see Ginatra::RepoList#find
    def self.find(local_param)
      self.instance.find(local_param)
    end

    # allows missing methods to cascade to the instance,
    #
    # @todo do we need this?
    # @todo update the respond_to? method if we do.
    #
    # Caution! contains: Magic
    def self.method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end
  end
end
