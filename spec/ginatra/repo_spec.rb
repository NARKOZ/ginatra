require 'spec_helper'

describe Ginatra::Repo do
  let(:repo) { Ginatra::RepoList.find('test') }

  it "has a name" do
    expect(repo.name).to eq('test')
  end

  it "has a param for urls" do
    expect(repo.param).to eq('test')
  end

  it "has an empty description" do
    expect(repo.description).to be_empty
  end

  it "has a list of commits" do
    expect(repo.commits).to_not be_empty
  end

  it "raises an error when asked to invert itself" do
    expect {
      repo.commits('master', -1)
    }.to raise_error(Ginatra::Error, 'max_count cannot be less than 0')
  end
end
