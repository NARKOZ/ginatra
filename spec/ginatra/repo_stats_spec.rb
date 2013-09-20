require 'spec_helper'

describe Ginatra::RepoStats do
  let(:repo) { Ginatra::RepoList.find('test') }

  it "#license" do
    expect(repo.license('master')).to eq('MIT')
  end
end
