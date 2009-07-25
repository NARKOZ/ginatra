module Ginatra
  # Convenience class for me!
  class Repo

    attr_reader :name, :param, :description

    def initialize(path)
      @repo = Grit::Repo.new(path)
      @param = File.split(path).last.gsub(/\.git$/, '')
      @name = @param.capitalize
      @description = @repo.description
      @description = "Please edit the #{@param}.git/description file for this repository and set the description for it." if /^Unnamed repository;/.match(@description)
      @repo
    end

    def commit(id)
      @commit = @repo.commit(id)
      raise(Ginatra::InvalidCommit.new(id)) if @commit.nil?
      add_refs(@commit)
      @commit
    end

    def commits(start = 'master', max_count = 10, skip = 0)
      raise(Ginatra::Error.new("max_count cannot be less than 0")) if max_count < 0
      @repo.commits(start, max_count, skip).each do |commit|
        add_refs(commit) 
      end
    end
    
    # TODO: Perhaps move into commit class.
    def add_refs(commit)
      commit.refs = []
      @repo.refs.select { |ref| ref.commit.id == commit.id }.each do |ref|
        commit.refs << ref
      end
    end

    def method_missing(sym, *args, &block)
      @repo.send(sym, *args, &block)
    end

  end

  class MultiRepo < Repo

    attr_reader :name, :param, :description

    def self.create!(param)
      @repo = MultiRepoList.find{ |r| r.param =~ /^#{Regexp.escape param }$/ }
    end
  end
end