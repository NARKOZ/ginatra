class MultiRepoList < RepoList
  def refresh
    Ginatra::Config.git_dirs.map! do |git_dir|
      files = Dir.glob(git_dir)
      files.each { |e| add(e) unless Ginatra::Config.ignored_files.include?(e) }
    end
  end
end