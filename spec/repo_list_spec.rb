$:.unshift File.dirname(__FILE__)
require "spec_helper"

describe "Ginatra" do

  describe "RepoList" do

    def current_path
      File.expand_path(File.dirname(__FILE__))
    end

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

      def print_repos_found
        Ginatra::Config.git_dirs.map! do |git_dir|
          files = Dir.glob(git_dir)
          files.each { |e| STDOUT.puts(e) unless Ginatra::Config.ignored_files.include?(File.split(e).last) }
        end
      end

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

        Ginatra::RepoList.instance.has_repo?(@new_repo_name).should == true

        new_repo = Ginatra::RepoList.find(@new_repo_name)
        repo_list.should include(new_repo)
      end

      it "should detect when a repo has been removed after refresh" do
        repo_list = Ginatra::RepoList.list # calling this should refresh the list

        Ginatra::RepoList.instance.has_repo?(@new_repo_name).should == true

        new_repo = Ginatra::RepoList.find(@new_repo_name)
        repo_list.should include(new_repo)

        # remove the new repository from the file system
        FileUtils.rm_rf File.join(@repo_dir, @new_repo_name), :secure => true

        repo_list = Ginatra::RepoList.list # refresh the repo list

        Ginatra::RepoList.instance.has_repo?(@new_repo_name).should == false
        repo_list.should_not include(new_repo)
      end

      after(:each) do
        FileUtils.rm_rf File.join(@repo_dir, @new_repo_name), :secure => true
      end
    end
  end
end
