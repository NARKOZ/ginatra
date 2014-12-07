require 'spec_helper'

describe Ginatra::Helpers do
  before { allow(Time).to receive(:now).and_return(Time.new(2012, 12, 25, 0, 0, 0, '+00:00')) }

  let(:repo)   { Ginatra::RepoList.find('test') }
  let(:commit) { repo.commit('095955b') }

  describe "#secure_mail" do
    it "returns masked email" do
      expect(secure_mail('eggscellent@example.com')).to eq('eggs...@example.com')
    end
  end

  describe "#gravatar_image_tag" do
    context "when options passed" do
      it "returns a gravatar image tag with custom options" do
        expect(
          gravatar_image_tag('john@example.com', size: 100, alt: 'John', class: 'avatar')
        ).to eq("<img src='https://secure.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=100' alt='John' height='100' width='100' class='avatar'>")
      end
    end

    context "when options not passed" do
      it "returns a gravatar image tag with default options" do
        expect(
          gravatar_image_tag('john@example.com')
        ).to eq("<img src='https://secure.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?s=40' alt='john' height='40' width='40'>")
      end
    end
  end

  describe "#file_icon" do
    context "symbolic link" do
      it "returns icon share-alt" do
        expect(file_icon(40960)).to eq("<span class='icon-share-alt'></span>")
      end
    end

    context "executable file" do
      it "returns icon asterisk" do
        expect(file_icon(33261)).to eq("<span class='icon-asterisk'></span>")
      end
    end

    context "non-executable file" do
      it "returns icon file" do
        expect(file_icon(33188)).to eq("<span class='icon-file'></span>")
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
      hint_text = "Edit `#{repo.path}description` file to set the repository description."
      expect(empty_description_hint_for(repo)).to eq("<span class='icon-exclamation-sign' title='#{hint_text}'></span>")
    end
  end

  describe "#atom_feed_url" do
    context "when ref name passed" do
      it "returns a link to repo reference atom feed" do
        expect(atom_feed_url('test', 'master')).to eq("/test/master.atom")
      end
    end

    context "when ref name not passed" do
      it "returns a link to repo atom feed" do
        expect(atom_feed_url('test')).to eq("/test.atom")
      end
    end
  end
end
