module Ginatra
  # Convenience class for me!
  class RepoList
    include Singleton
    attr_accessor :list
    def initialize

      self.list = []
      self.refresh
    end
    
    # For convinience
    def self.list
      self.instance.refresh
      self.instance.list
    end

    def refresh
      Dir.entries(Ginatra::Config.git_dir).
        delete_if{ |e| Ginatra::Config.ignored_files.include?(e) }.
        each { |e| add(e) }
    end

    def add(e, path = File.expand_path(e, Ginatra::Config.git_dir))
      unless self.has_repo?(e)
        list << Repo.new(path)
      end
    end

    def has_repo?(local_param)
      l = local_param.sub(/\.git$/,'')
      list.find { |r| r.param == l } ? true : false
    end

    def find(local_param)
      if repo = list.find { |r| r.param == local_param }
        repo
      else
        refresh
        list.find { |r| r.param == local_param }
      end
    end

    def self.find(local_param)
      self.instance.find(local_param)
    end

    def self.method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end
  end

  class MultiRepoList < RepoList
    def initialize
      self.list = []
      Ginatra::Config.git_dirs.each do |git_dir|
        self.list << Dir.glob(git_dir).
                          delete_if{ |e| Ginatra::Config.ignored_files.include?(e) }.
                          map{ |e| File.expand_path(e) }
      end
      self.list.flatten!
      self.list.map!{ |e| Repo.new(e) }
    end
  end
end
