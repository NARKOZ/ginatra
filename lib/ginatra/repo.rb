module Ginatra
  # Convenience class for me!
  class Repo

    attr_reader :name, :param, :description

    def initialize(path)
      @repo = Grit::Repo.new(path)
      @param = File.split(path).last.gsub(/\.git$/, '')
      @name = @param.capitalize
      @description = "Please edit the #{@param}.git/description file for this repository and set the description for it." if /^Unnamed repository;/.match(@repo.description)
      @repo
    end

    def method_missing(sym, *args, &block)
      @repo.send(sym, *args, &block)
    end
  end

  class MultiRepo < Repo

    attr_reader :name, :param, :description

    def self.create!(param)
      @repo_list = MultiRepoList.new
      @repo = @repo_list.find{|r| r.param =~ /^#{Regexp.escape param }$/}
    end
  end
end