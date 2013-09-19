require 'spec_helper'

describe Ginatra::Helpers do
  before { Time.stub(:now).and_return(Time.new(2012, 12, 25, 0, 0, 0, '+00:00')) }

  let(:repo)   { Ginatra::RepoList.find('test') }
  let(:commit) { repo.commit('095955b') }

  describe "#gravatar_url" do
    context "when size passed" do
      it "returns a gravatar url with defined size" do
        expect(
          gravatar_url('john@example.com', 100)
        ).to eq('https://secure.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=100')
      end
    end

    context "when size not passed" do
      it "returns a gravatar url with default size" do
        expect(
          gravatar_url('john@example.com')
        ).to eq('https://secure.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=40')
      end
    end
  end

  describe "#nicetime" do
    it "returns a time in nice format" do
      expect(nicetime(Time.now)).to eq('Dec 25, 2012 &ndash; 00:00')
    end
  end

  describe "#time_tag" do
    it "returns a time in nice format" do
      expect(
        time_tag(Time.now)
      ).to eq("<time datetime='2012-12-25T00:00:00+0000' title='2012-12-25 00:00:00'>December 25, 2012 00:00</time>")
    end
  end

  describe "#patch_link" do
    it "returns a link for a commit patch" do
      expect(
        patch_link(commit, 'test')
      ).to eq("<a href='/test/commit/095955b6402c30ef24520bafdb8a8687df0a98d3.patch'>Download Patch</a>")
    end
  end

  describe "#empty_description_hint_for" do
    it "returns a hint for a repo with empty description" do
      hint_text = "Please edit the #{repo.path}description file for this repository and set the description for it."
      expect(empty_description_hint_for(repo)).to eq("<i class='icon-exclamation-sign' title='#{hint_text}'></i>")
    end
  end

  describe "#atom_feed_link" do
    context "when ref name passed" do
      it "returns a link to repo reference atom feed" do
        expect(atom_feed_link('test', 'master')).to eq("<a href='/test/master.atom'>Feed</a>")
      end
    end

    context "when ref name not passed" do
      it "returns a link to repo atom feed" do
        expect(atom_feed_link('test')).to eq("<a href='/test.atom'>Feed</a>")
      end
    end
  end
end
