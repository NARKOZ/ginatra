require File.join(File.dirname(__FILE__), "spec_helper")

describe "Ginatra" do
  
  before do
    @repo_list = Ginatra::RepoList.instance
    @multi_repo_list = Ginatra::MultiRepoList.instance
  end
    

  describe "Repo" do

    before do
      @ginatra_repo = @repo_list.find("test")
      @grit_repo = Grit::Repo.new(File.join(Ginatra::App.git_dir, "test.git"), {})
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

  end

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

  describe "MultiRepo" do

    before(:each) do
      @ginatra_multirepo = @multi_repo_list.find("test")
      @grit_repo = Grit::Repo.new(File.join(Ginatra::App.git_dir, "test.git"))
    end

    it "should have a name" do
      @ginatra_multirepo.name == "Test"
    end

    it "should have a param for urls" do
      @ginatra_multirepo.name == "test"
    end

    it "should have a description" do
      @ginatra_multirepo.description == "Unnamed repository; edit this file to name it for gitweb."
    end

    it "should have a descripton that matches the grit description" do
      @ginatra_multirepo.description == @grit_repo.description
    end

    it "should have an array of commits that match the grit array of commits limited to 25 items" do
      @ginatra_multirepo.commits === @grit_repo.commits
      @ginatra_multirepo.commits.length == 10
    end

    it "should create the same thing using .create! or .new" do
      @multi_repo_list.find("test") == Ginatra::MultiRepo.new(File.join(Ginatra::App.git_dir, "test.git"))
    end

  end

  describe "MultiRepoList" do

    before(:each) do
      @repo = @multi_repo_list.find("test")
    end

    it "should be an array of `Ginatra::Repo`s" do
      @multi_repo_list.each { |r| r.should be_an_instance_of(Ginatra::MultiRepo)}
    end

    it "should contain the test repo" do
      @multi_repo_list.include?(@repo)
    end

  end

end
