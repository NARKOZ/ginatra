require 'spec_helper'

describe Ginatra::RepoStats do
  let(:repo)       { Ginatra::RepoList.find('test') }
  let(:repo_stats) { Ginatra::RepoStats.new(repo, 'master') }

  it "#license" do
    expect(repo_stats.license).to eq('MIT')
  end

  it "#commits_count" do
    expect(repo_stats.commits_count).to eq(57)
  end

  it "#contributors" do
    contributors = repo_stats.contributors
    expect(contributors).to be_a_kind_of(Array)
    expect(contributors.size).to eq(2)
    expect(contributors.first).to eq(['atmos@atmos.org', { author: 'Corey Donohoe', commits_count: 55 }])
  end

  it "#created_at" do
    created_at = repo_stats.created_at
    expect(created_at).to be_a_kind_of(Time)
    expect(created_at.to_s).to eq('2009-03-04 21:47:31 +0400')
  end
end
