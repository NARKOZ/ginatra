require 'spec_helper'

describe Ginatra::Repo do
  before do
    @ginatra_repo = Ginatra::RepoList.find("test")
    @repo = Rugged::Repository.new(File.join(current_path, "..", "repos", "test"))
    @commit = @ginatra_repo.commit("095955b")
  end

  it "should have a name" do
    @ginatra_repo.name.should == "test"
  end

  it "should have a param for urls" do
    @ginatra_repo.param.should == 'test'
  end

  it "should have an empty description" do
    @ginatra_repo.description.should be_empty
  end

  it "should have a list of commits" do
    @ginatra_repo.commits.should_not be_empty
  end

  it "should raise an error when asked to invert itself" do
    expect {
      @ginatra_repo.commits("master", -1)
    }.to raise_error(Ginatra::Error, "max_count cannot be less than 0")
  end
end
