module Ginatra
  # Convenience class for me!
  class RepoList

    def initialize
      @repo_list = Dir.entries(Ginatra::App.git_dir).
                   delete_if{ |e| Ginatra::App.ignored_files.include?(e) }.
                   map!{ |e| File.expand_path(e, Ginatra::App.git_dir) }.
                   map!{ |e| Repo.new(e) }
    end

    def find(local_param)
      @repo_list.find{ |r| r.param == local_param }
    end

    def method_missing(sym, *args, &block)
      @repo_list.send(sym, *args, &block)
    end
  end

  class MultiRepoList < RepoList
    def initialize
      @repo_list = []
      Ginatra::App.git_dirs.each do |git_dir|
        @repo_list << Dir.glob(git_dir).
                          delete_if{ |e| Ginatra::App.ignored_files.include?(e) }.
                          map{ |e| File.expand_path(e) }
      end
      @repo_list.flatten!
      @repo_list.map!{ |e| MultiRepo.new(e) }
    end
  end
end