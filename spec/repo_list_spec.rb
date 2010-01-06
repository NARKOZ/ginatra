current_path = File.expand_path(File.dirname(__FILE__))
require File.join(current_path, "spec_helper")

describe "Ginatra" do

  describe "RepoList" do

    before do
      @repo_list = Ginatra::RepoList.list
      @repo = Ginatra::RepoList.find("test")
    end

    it "should be an array of `Ginatra::Repo`s" do
      @repo_list.each { |r| r.should be_an_instance_of(Ginatra::Repo)}
    end

    it "should contain the test repo" do
      @repo_list.include?(@repo)
    end

    it "has_repo? works for existing repo" do
      Ginatra::RepoList.instance.has_repo?("test").should == true
    end

    it "has_repo? works for non-existant repo" do
      Ginatra::RepoList.instance.has_repo?("bad-test").should == false
    end

    describe "New repos added to repo directory" do

      NEW_REPO_NAME = "temp-new-repo"
      REPO_DIR = File.join(current_path, "..", "repos")

      def print_repos_found
        Ginatra::Config.git_dirs.map! do |git_dir|
          files = Dir.glob(git_dir)
          files.each { |e| STDOUT.puts(e) unless Ginatra::Config.ignored_files.include?(File.split(e).last) }
        end
      end

      before(:each) do
        FileUtils.cd(REPO_DIR) do |dir|
          FileUtils.mkdir(NEW_REPO_NAME)
          FileUtils.cd(NEW_REPO_NAME) do |dir|
            `git init`
          end
        end
      end

      it "should detect new repo after refresh" do
        repo_list = Ginatra::RepoList.list # calling this should refresh the list

        Ginatra::RepoList.instance.has_repo?(NEW_REPO_NAME).should == true

        new_repo = Ginatra::RepoList.find(NEW_REPO_NAME)
        repo_list.should include(new_repo)
      end

      it "should detect when a repo has been removed after refresh" do
        repo_list = Ginatra::RepoList.list # calling this should refresh the list

        Ginatra::RepoList.instance.has_repo?(NEW_REPO_NAME).should == true

        new_repo = Ginatra::RepoList.find(NEW_REPO_NAME)
        repo_list.should include(new_repo)

        # remove the new repository from the file system
        FileUtils.rm_rf File.join(REPO_DIR, NEW_REPO_NAME), :secure => true

        repo_list = Ginatra::RepoList.list # refresh the repo list

        Ginatra::RepoList.instance.has_repo?(NEW_REPO_NAME).should == false
        repo_list.should_not include(new_repo)
      end

      after(:each) do
        FileUtils.rm_rf File.join(REPO_DIR, NEW_REPO_NAME), :secure => true
      end
    end
  end
end
