module Ginatra
  # Convenience class for me!
  class RepoList
    include Singleton
    attr_accessor :list
    
    def initialize
      self.list = []
      self.refresh
    end
    
    def self.list
      self.instance.refresh
      self.instance.list
    end

    def refresh
      entries = Dir.entries(Ginatra::Config.git_dir)
      entries.each { |e| add(e) unless Ginatra::Config.ignored_files.include?(e) }
    end

    def add(e, path = File.expand_path(e, Ginatra::Config.git_dir))
      unless self.has_repo?(e)
        list << Repo.new(path)
      end
    end

    def has_repo?(local_param)
      l = local_param.sub(/\.git$/,'')
      !list.find { |r| r.param == l }.nil?
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
    def refresh
      Ginatra::Config.git_dirs.map! do |git_dir|
        files = Dir.glob(git_dir)
        files.delete_if { |e| Ginatra::Config.ignored_files.include?(e) }
        files.each { |e| add(e) }
      end
    end
  end
end
