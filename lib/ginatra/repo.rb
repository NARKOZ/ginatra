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
      @description = ''
      if File.exists?("#{@repo.path}description")
        @description = File.read("#{@repo.path}description").strip
        @description = '' if @description.match(/\AUnnamed repository;/)
      end
    end

    # Return a commit corresponding to sha in the repo.
    #
    # @param [String] sha the commit id or tag name
    # @return [Rugged::Commit] the commit object
    def commit(sha)
      @repo.lookup(sha)
    end

    # Return a commit corresponding to tag in the repo.
    def commit_by_tag(name)
      target = @repo.ref("refs/tags/#{name}").target

      if target.is_a? Rugged::Tag::Annotation
        target = target.target
      end

      target
    end

    # Return a list of commits in a certain branch, including pagination options and all the refs.
    #
    # @param [String] start the branch to look for commits in
    # @param [Integer] max_count the maximum count of commits
    # @param [Integer] skip the number of commits in the branch to skip before taking the count.
    #
    # @return [Array<Rugged::Commit>] the array of commits.
    def commits(branch = 'master', max_count = 10, skip = 0)
      fail Ginatra::InvalidRef unless branch_exists?(branch)

      walker = Rugged::Walker.new(@repo)
      walker.sorting(Rugged::SORT_TOPO)
      walker.push(@repo.ref("refs/heads/#{branch}").target)

      commits = walker.collect { |commit| commit }
      commits[skip, max_count]
    end

    # Returns list of branches sorted by name alphabetically
    def branches
      @repo.branches.each(:local).sort_by { |b| b.name }
    end

    # Returns list of branches containing the commit
    def branches_with(commit)
      b = []
      branches.each do |branch|
        walker = Rugged::Walker.new(@repo)
        walker.sorting(Rugged::SORT_TOPO)
        walker.push(@repo.ref("refs/heads/#{branch.name}").target)
        walker.collect { |c| b << branch if c.oid == commit }
      end
      b
    end

    # Checks existence of branch by name
    def branch_exists?(branch_name)
      @repo.branches.exists?(branch_name)
    end

    # Find blob by oid
    def find_blob(oid)
      Rugged::Blob.new @repo, oid
    end

    # Find tree by tree oid or branch name
    def find_tree(oid)
      if branch_exists?(oid)
        last_commit_sha = @repo.ref("refs/heads/#{oid}").target.oid
        lookup(last_commit_sha).tree
      else
        lookup(oid)
      end
    end

    # Returns Rugged::Repository instance
    def to_rugged
      @repo
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
