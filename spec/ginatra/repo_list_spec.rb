require 'spec_helper'

describe Ginatra::RepoList do
  before do
    @repo_list = Ginatra::RepoList.list
    @repo = Ginatra::RepoList.find("test")
  end

  it "should be an array of `Ginatra::Repo`s" do
    @repo_list.each {|r| r.should be_an_instance_of(Ginatra::Repo)}
  end

  it "should contain the test repo" do
    @repo_list.should include(@repo)
  end

  it "has_repo? works for existing repo" do
    Ginatra::RepoList.instance.has_repo?("test").should be_true
  end

  it "has_repo? works for non-existant repo" do
    Ginatra::RepoList.instance.has_repo?("bad-test").should be_false
  end

  describe "New repos added to repo directory" do
    before(:each) do
      @new_repo_name = "temp-new-repo"
      @repo_dir = File.join(current_path, "..", "repos")

      FileUtils.cd(@repo_dir) do |dir|
        FileUtils.mkdir(@new_repo_name)
        FileUtils.cd(@new_repo_name) do |dir|
          `git init`
        end
      end
    end

    it "should detect new repo after refresh" do
      repo_list = Ginatra::RepoList.list # calling this should refresh the list
      Ginatra::RepoList.instance.has_repo?(@new_repo_name).should be_true

      new_repo = Ginatra::RepoList.find(@new_repo_name)
      repo_list.should include(new_repo)
    end

    it "should detect when a repo has been removed after refresh" do
      repo_list = Ginatra::RepoList.list # calling this should refresh the list
      Ginatra::RepoList.instance.has_repo?(@new_repo_name).should be_true

      new_repo = Ginatra::RepoList.find(@new_repo_name)
      repo_list.should include(new_repo)

      # remove the new repository from the file system
      FileUtils.rm_rf File.join(@repo_dir, @new_repo_name), :secure => true

      repo_list = Ginatra::RepoList.list # refresh the repo list

      Ginatra::RepoList.instance.has_repo?(@new_repo_name).should be_false
      repo_list.should_not include(new_repo)
    end

    after(:each) do
      FileUtils.rm_rf File.join(@repo_dir, @new_repo_name), :secure => true
    end
  end
end
