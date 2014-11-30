require 'spec_helper'

describe Ginatra::Repo do
  let(:repo) { Ginatra::RepoList.find('test') }

  describe "repo" do
    it "returns name" do
      expect(repo.name).to eq("test")
    end

    it "returns param" do
      expect(repo.param).to eq("test")
    end

    it "returns description" do
      expect(repo.description).to eq("")
    end
  end

  describe "#commit" do
    it "returns commit by sha" do
      commit = repo.commit '095955b'
      expect(commit).to be_a_kind_of(Rugged::Commit)
      expect(commit.oid).to eq('095955b6402c30ef24520bafdb8a8687df0a98d3')
    end
  end

  describe "#commit_by_tag" do
    it "returns commit by tag" do
      commit = repo.commit_by_tag 'v0.0.3'
      expect(commit).to be_a_kind_of(Rugged::Commit)
      expect(commit.oid).to eq('0c386b293878fb5f69031a998d564ecb8c2fee4d')
    end
  end

  describe "#commits" do
    it "returns an array of commits" do
      commits = repo.commits('master', 2)
      expect(commits).to be_a_kind_of(Array)
      expect(commits.size).to eq(2)
      expect(commits.first.oid).to eq('095955b6402c30ef24520bafdb8a8687df0a98d3')
    end
  end

  describe "#branches" do
    it "returns an array of branches" do
      branches = repo.branches
      expect(branches).to be_a_kind_of(Array)
      expect(branches.size).to eq(1)
      expect(branches.first.name).to eq('master')
      expect(branches.first.target).to eq('095955b6402c30ef24520bafdb8a8687df0a98d3')
    end
  end

  describe "#branches_with" do
    it "returns an array of branches including commit" do
      branches = repo.branches_with('095955b6402c30ef24520bafdb8a8687df0a98d3')
      expect(branches).to be_a_kind_of(Array)
      expect(branches.size).to eq(1)
      expect(branches.first.name).to eq('master')
    end
  end

  describe "#branch_exists?" do
    it "checks existence of branch" do
      expect(repo.branch_exists?('master')).to be true
      expect(repo.branch_exists?('master-404')).to be false
    end
  end
end
