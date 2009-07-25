require File.join(File.dirname(__FILE__), "spec_helper")

describe "Ginatra" do
  describe "Repo" do
   
    before do
      @repo_list = Ginatra::RepoList
      @ginatra_repo = @repo_list.find("test")
      @grit_repo = Grit::Repo.new(File.join(Ginatra::App.git_dir, "test.git"), {})
      @commit = @ginatra_repo.commit("a21409da199337fb4ba4cde4be8f82f38397782a")
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

    it "should be the same thing using #find or #new" do
      @repo_list.find("test") == Ginatra::Repo.new(File.join(Ginatra::App.git_dir, "test.git"))
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