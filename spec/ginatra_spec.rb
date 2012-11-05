require 'spec_helper'

describe Ginatra do
  before do
    @repo = Grit::Repo.new(File.join(current_path, "..", "repos", "test"))
  end

  describe "main page" do
    it "should respond with 200" do
      get '/'
      last_response.status.should == 200
    end
  end

  describe "repo commits atom feed" do
    it "should respond with 200" do
      get '/test.atom'
      last_response.status.should == 200
    end

    it "should return application/xml" do
      get '/test.atom'
      last_response.headers['Content-Type'].should match("application/xml.*")
    end
  end

  describe "repo page" do
    it "should respond with 200" do
      get '/test'
      last_response.status.should == 200
    end
  end

  describe "repo graph page" do
    it "should respond with 200" do
      get '/test/graph'
      last_response.status.should == 200
    end
  end

  describe "branch commits atom feed" do
    it "should respond with 200" do
      get '/test/master.atom'
      last_response.status.should == 200
    end

    it "should return application/xml" do
      get '/test/master.atom'
      last_response.headers['Content-Type'].should match("application/xml.*")
    end
  end

  describe "repo branch page" do
    it "should respond with 200" do
      get '/test/master'
      last_response.status.should == 200
    end
  end

  describe "repo commit patch" do
    it "should respond with 200" do
      get "/test/commit/master.patch"
      last_response.status.should == 200
    end

    it "should return text/plain" do
      get "/test/commit/master.patch"
      last_response.headers['Content-Type'].should match("text/plain.*")
    end
  end

  describe "repo commit page" do
    it "should respond with 200" do
      get "/test/commit/master"
      last_response.status.should == 200
    end
  end

  describe "repo tree archive" do
    it "should respond with 200" do
      get "/test/archive/master.tar.gz"
      last_response.status.should == 200
    end

    it "should return application/x-tar-gz" do
      get "/test/archive/master.tar.gz"
      last_response.headers['Content-Type'].should == "application/x-gzip"
    end
  end

  describe "repo tree page" do
    it "should respond with 200" do
      get "/test/tree/master"
      last_response.status.should == 200
    end
  end

  describe "repo tree page with path" do
    it "should respond with 200" do
      get "/test/tree/master/examples"
      last_response.status.should == 200
    end
  end

  describe "repo blob page" do
    it "should respond with 200" do
      get "/test/blob/45f84f90093187e0a2fadf6645de49a3f520fffe"
      last_response.status.should == 200
    end
  end

  describe "repo blob page with path" do
    it "should respond with 200" do
      get '/test/blob/master/Gemfile'
      last_response.status.should == 200
    end
  end

  describe "repo log page" do
    it "should respond with 200" do
      get '/test/master/page/1'
      last_response.status.should == 200
    end
  end
end
