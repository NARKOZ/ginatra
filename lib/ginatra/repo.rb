require 'rugged'

module Ginatra
  class Repo
    attr_reader :name, :param, :description

    # Create a new repository, and sort out clever stuff including assigning
    # the param, the name and the description.
    #
    # @param [String] path a path to the repository you want created
    # @return [Ginatra::Repo] a repository instance
    def initialize(path)
      @repo = Rugged::Repository.new(path)
      @param = File.split(path).last
      @name = @param
      @description = File.read("#{@repo.path}description").strip
      @description = "Please edit the #{@repo.path}description file for this repository and set the description for it." if /^Unnamed repository;/.match(@description)
    end

    # Return a commit corresponding to sha in the repo.
    #
    # @param [String] sha the commit id or tag name
    # @return [Grit::Commit] the commit object
    def commit(sha)
      @repo.lookup(sha)
    end

    # Return a tag by name in the repo.
    def tag(name)
      ref = @repo.ref("refs/tags/#{name}")
      @repo.lookup(ref.target)
    end

    # Return a list of commits in a certain branch, including pagination options and all the refs.
    #
    # @param [String] start the branch to look for commits in
    # @param [Integer] max_count the maximum count of commits
    # @param [Integer] skip the number of commits in the branch to skip before taking the count.
    #
    # @raise [Ginatra::Error] if max_count is less than 0. silly billy!
    #
    # @return [Array<Grit::Commit>] the array of commits.
    def commits(branch='master', max_count=10, skip=0)
      raise Ginatra::Error.new("max_count cannot be less than 0") if max_count < 0
      walker = Rugged::Walker.new(@repo)
      walker.sorting(Rugged::SORT_TOPO)
      walker.push(@repo.ref("refs/heads/#{branch}").target)

      commits = walker.collect {|commit| commit }
      commits[skip, max_count]
    end

    # Returns list of branches sorted by name alphabetically
    def branches
      Rugged::Branch.each(@repo, :local).sort
    end

    # Checks existence of branch by name
    def branch_exists?(branch_name)
      !Rugged::Branch.lookup(@repo, branch_name).nil?
    end

    # Find blob by oid
    def find_blob(oid)
      Rugged::Blob.new @repo, oid
    end

    # Find tree by tree oid or branch name
    def find_tree(oid)
      if branch_exists?(oid)
        last_commit_sha = @repo.ref("refs/heads/#{oid}").target
        lookup(last_commit_sha).tree
      else
        lookup(oid)
      end
    end

    # Catch all
    #
    # @todo update respond_to? method
    def method_missing(sym, *args, &block)
      if @repo.respond_to?(sym)
        @repo.send(sym, *args, &block)
      else
        super
      end
    end

    # to correspond to the #method_missing definition
    def respond_to?(sym)
      @repo.respond_to?(sym) || super
    end
  end
end
