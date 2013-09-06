require 'spec_helper'

describe Ginatra::Helpers do
  before do
    @repo = Ginatra::RepoList.find('test')
    @commit = @repo.commit('095955b')
    Time.stub(:now).and_return(Time.new(2012, 12, 25, 0, 0, 0, '+00:00'))
  end

  describe "#gravatar_url" do
    context "when size passed" do
      it "should return a gravatar url" do
        gravatar_url('john@example.com', 100).should ==
          'https://secure.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=100'
      end
    end

    context "when size not passed" do
      it "should return a gravatar url" do
        gravatar_url('john@example.com').should ==
          'https://secure.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=40'
      end
    end
  end

  describe "#nicetime" do
    it "should return a time in nice format" do
      nicetime(Time.now).should == 'Dec 25, 2012 &ndash; 00:00'
    end
  end

  describe "#time_tag" do
    it "should return a time in nice format" do
      time_tag(Time.now).should ==
        "<time datetime='2012-12-25T00:00:00+0000' title='2012-12-25 00:00:00'>December 25, 2012 00:00</time>"
    end
  end

  describe "#patch_link" do
    it "should return a link for a commit patch" do
      patch_link(@commit, 'test').should ==
        "<a href='/test/commit/095955b6402c30ef24520bafdb8a8687df0a98d3.patch'>Download Patch</a>"
    end
  end

  describe "#atom_feed_link" do
    context "when ref name passed" do
      it "should return a link to repo reference atom feed" do
        atom_feed_link('test', 'master').should == "<a href='/test/master.atom'>Feed</a>"
      end
    end

    context "when ref name not passed" do
      it "should return a link to repo atom feed" do
        atom_feed_link('test').should == "<a href='/test.atom'>Feed</a>"
      end
    end
  end
end
