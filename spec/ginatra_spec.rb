require 'spec_helper'

describe Ginatra::App do
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
      get "/test/commit/095955b.patch"
      last_response.status.should == 200
    end

    it "should return text/plain" do
      get "/test/commit/095955b.patch"
      last_response.headers['Content-Type'].should match("text/plain.*")
    end
  end

  describe "repo commit page" do
    it "should respond with 200" do
      get "/test/commit/095955b"
      last_response.status.should == 200
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
