require 'spec_helper'

describe Ginatra::GraphCommit do
  before do
    @ginatra_repo = Ginatra::RepoList.find("test")
    @list_of_commits = @ginatra_repo.all_commits
    @map_of_commits = {}
    @list_of_commits.each {|c| @map_of_commits[c.id] = c }
  end

  it "should have a time param" do
    @list_of_commits.first.time = 132
    @list_of_commits.first.time.should == 132
  end

  it "should have a space param" do
    @list_of_commits.first.space = 0
    @list_of_commits.first.space.should == 0
  end

  it "should mark all commits from given branch" do
    Ginatra::GraphCommit.mark_chain(11, @list_of_commits.first, @map_of_commits)
    @list_of_commits.each {|c| c.space.should >= 11}
  end

  it "should put time on each commit from the list" do
    Ginatra::GraphCommit.index_commits @list_of_commits
    @list_of_commits.each {|c| c.time.should >= 0}
  end

  it "should put space on each commit reachable from any named head from the list" do
    Ginatra::GraphCommit.index_commits @list_of_commits
    @list_of_commits.each {|c| c.space.should > 0}
  end

  it "should make list of days coraleted with commits" do
    days = Ginatra::GraphCommit.index_commits @list_of_commits
    @list_of_commits.reverse.each_with_index {|c,i| days[i].should == c.committed_date}
  end

  it "should make master on space 1" do
    Ginatra::GraphCommit.index_commits @list_of_commits
    master_commit = @ginatra_repo.commits('master').first
    @list_of_commits.each{|c| c.space.should == 1 if c.id == master_commit.id}
  end
end
