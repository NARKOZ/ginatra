$:.unshift File.dirname(__FILE__)
require "spec_helper"

describe "Ginatra" do
  describe "Repo" do

    def current_path
      File.expand_path(File.dirname(__FILE__))
    end

    before do
      @repo_list = Ginatra::RepoList
      @ginatra_repo = @repo_list.find("test")
      @grit_repo = Grit::Repo.new(File.join(current_path, "..", "repos", "test"), {})
      @commit = @ginatra_repo.commit("910ff56f585bcdfc3ba105c8846b1df0a6abf069")
    end

    it "should have a name" do
      @ginatra_repo.name == "test"
    end

    it "should have a param for urls" do
      @ginatra_repo.param == 'test'
    end

    it "should have a description" do
      @ginatra_repo.description =~ /description file for this repository and set the description for it./
    end

    it "should have an array of commits that match the grit array of commits limited to 10 items" do
      @ginatra_repo.commits === @grit_repo.commits
      @ginatra_repo.commits.length == 10
    end

    it "should be the same thing using #find or #new" do
      @repo_list.find("test") == Ginatra::Repo.new(File.join(current_path, "..", "repos", "test"))
    end

    it "should contain this commit" do
      @commit.refs.should_not be_empty
    end

    it "should not contain this other commit" do
      lambda { @ginatra_repo.commit("totallyinvalid") }.should raise_error(Ginatra::InvalidCommit, "Could not find a commit with the id of totallyinvalid")
    end

    it "should have a list of commits" do
      @ginatra_repo.commits.should_not be_blank
    end

    it "should raise an error when asked to invert itself" do
      lambda { @ginatra_repo.commits("master", -1) }.should raise_error(Ginatra::Error, "max_count cannot be less than 0")
    end

    it "should be able to add refs to a commit" do
      @commit.refs = []
      @ginatra_repo.add_refs(@commit)
      @commit.refs.should_not be_empty
    end

  end
end