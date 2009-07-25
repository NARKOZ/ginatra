require File.join(File.dirname(__FILE__), "spec_helper")
describe "Ginatra" do
  
  describe "RepoList" do

    before do
      @repo = @repo_list.find("test")
    end

    it "should be an array of `Ginatra::Repo`s" do
      @repo_list.each { |r| r.should be_an_instance_of(Ginatra::Repo)}
    end

    it "should contain the test repo" do
      @repo_list.include?(@repo)
    end

  end
end