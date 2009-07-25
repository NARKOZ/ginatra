module Ginatra
  # Convenience class for me!
  class RepoList
    include Singleton
    attr_accessor :list
    def initialize

      self.list =  Dir.entries(Ginatra::Config.git_dir).
                   delete_if{ |e| Ginatra::Config.ignored_files.include?(e) }.
                   map!{ |e| File.expand_path(e, Ginatra::Config.git_dir) }.
                   map!{ |e| Repo.new(e) }
    end
    
    # For convinience
    def self.list
      self.instance.list
    end
    
    def self.find(local_param)
      list.find { |r| r.param == local_param }
    end

    def self.method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end
  end

  class MultiRepoList < RepoList
    def initialize
      @repo_list = []
      Ginatra::Config.git_dirs.each do |git_dir|
        @repo_list << Dir.glob(git_dir).
                          delete_if{ |e| Ginatra::Config.ignored_files.include?(e) }.
                          map{ |e| File.expand_path(e) }
      end
      @repo_list.flatten!
      @repo_list.map!{ |e| MultiRepo.new(e) }
    end
  end
end