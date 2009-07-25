module Ginatra
  # Convenience class for me!
  class RepoList
    include Singleton
    
    def self.list
      Dir.entries(Ginatra::Config.git_dir).
                     delete_if{ |e| Ginatra::Config.ignored_files.include?(e) }.
                     map!{ |e| File.expand_path(e, Ginatra::Config.git_dir) }.
                     map!{ |e| Repo.new(e) }
    end
    
    def self.find(local_param)
      list.find { |r| r.param == local_param }
    end

    def self.method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end
  end

  class MultiRepoList < RepoList
    def self.list
      Ginatra::Config.git_dirs.map! do |git_dir|
        files = Dir.glob(git_dir)
        files.delete_if { |e| Ginatra::Config.ignored_files.include?(e) }
        files.map! { |e| File.expand_path(e) }
      end.flatten.map! { |e| Repo.new(e) }
    end
  end
end