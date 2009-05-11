require File.join(File.dirname(__FILE__), "spec_helper")

# describe Bowling do
#   it "hates everyone" do
#     Object.should hate(everyone)
#   end
# end

describe Ginatra::Repo do
  before(:each) do
    @ginatra_repo = Ginatra::Repo.new("test")
    @grit_repo = Grit::Repo.new(File.join(Sinatra::Application.git_dir, "test.git"), {})
  end
  it "should have a name" do
    @ginatra_repo.name == "Test"
  end
  it "should have a param for urls" do
    @ginatra_repo.param == 'test'
  end
  it "should have a description" do
    @ginatra_repo.description == "Unnamed repository; edit this file to name it for gitweb."
  end
  it "should have a descripton that matches the grit description" do
    @ginatra_repo.description == @grit_repo.description
  end
  it "should have an array of commits that match the grit array of commits limited to 25 items" do
    @ginatra_repo.commits === @grit_repo.commits
    @ginatra_repo.commits.length == 10
  end
end
describe Ginatra::RepoList do
  before(:each) do
    @repo_list = Ginatra::RepoList.new
    @repo = Ginatra::Repo.new("test")
  end
  it "should be an array of `Ginatra::Repo`s" do
    @repo_list.each { |r| r.should be_an_instance_of(Ginatra::Repo)}
  end
  it "should contain the test repo" do
    @repo_list.include?(@repo)
  end
end

