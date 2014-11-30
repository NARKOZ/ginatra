require 'spec_helper'

describe Ginatra::RepoList do
  let(:repo)      { Ginatra::RepoList.find('test') }
  let(:repo_list) { Ginatra::RepoList.list }

  it "is an array of 'Ginatra::Repo'" do
    repo_list.each do |repo|
      expect(repo).to be_an_instance_of(Ginatra::Repo)
    end
  end

  it "contains the test repo" do
    expect(repo_list).to include(repo)
  end

  it "has_repo? works for existing repo" do
    expect(Ginatra::RepoList.instance.has_repo?('test')).to be true
  end

  it "has_repo? works for non-existant repo" do
    expect(Ginatra::RepoList.instance.has_repo?('bad-test')).to be false
  end

  describe "New repos added to repo directory" do
    before(:each) do
      @new_repo_name = 'temp-new-repo'
      @repo_dir = File.join(current_path, '..', 'repos')

      FileUtils.cd(@repo_dir) do |repo_dir|
        FileUtils.mkdir_p(@new_repo_name)
        FileUtils.cd(@new_repo_name) do |new_repo_dir|
          `git init`
        end
      end
    end

    it "should detect new repo after refresh" do
      repo_list = Ginatra::RepoList.list # calling this should refresh the list
      expect(Ginatra::RepoList.instance.has_repo?(@new_repo_name)).to be true

      new_repo = Ginatra::RepoList.find(@new_repo_name)
      expect(repo_list).to include(new_repo)
    end

    it "should detect when a repo has been removed after refresh" do
      repo_list = Ginatra::RepoList.list # calling this should refresh the list
      expect(Ginatra::RepoList.instance.has_repo?(@new_repo_name)).to be true

      new_repo = Ginatra::RepoList.find(@new_repo_name)
      expect(repo_list).to include(new_repo)

      # remove the new repository from the file system
      FileUtils.rm_rf File.join(@repo_dir, @new_repo_name), secure: true

      repo_list = Ginatra::RepoList.list # refresh the repo list

      expect(Ginatra::RepoList.instance.has_repo?(@new_repo_name)).to be false
      expect(repo_list).to_not include(new_repo)
    end

    after(:each) do
      FileUtils.rm_rf File.join(@repo_dir, @new_repo_name), secure: true
    end
  end
end
