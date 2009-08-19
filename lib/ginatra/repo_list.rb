require 'singleton'

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
      Ginatra::Config.git_dirs.map! do |git_dir|
        files = Dir.glob(git_dir)
        files.each { |e| add(e) unless Ginatra::Config.ignored_files.include?(File.split(e).last) }
      end
    end

    def add(path, param = File.split(path).last)
      unless self.has_repo?(param)
        list << Repo.new(path)
      end
    end

    def has_repo?(local_param)
      !list.find { |r| r.param == local_param }.nil?
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
end
