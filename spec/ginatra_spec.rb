require 'spec_helper'

describe Ginatra::App do
  describe 'main page' do
    it 'returns http success' do
      get '/'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo commits atom feed' do
    it 'returns http success' do
      get '/test.atom'
      expect(last_response.status).to eq(200)
    end

    it 'returns application/xml' do
      get '/test.atom'
      expect(last_response.headers['Content-Type']).to match('application/xml.*')
    end
  end

  describe 'repo page' do
    it 'returns http success' do
      get '/test'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo stats page' do
    it 'returns http success' do
      get '/test/stats/master'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'branch commits atom feed' do
    it 'returns http success' do
      get '/test/master.atom'
      expect(last_response.status).to eq(200)
    end

    it 'returns application/xml' do
      get '/test/master.atom'
      expect(last_response.headers['Content-Type']).to match('application/xml.*')
    end
  end

  describe 'repo branch page' do
    it 'returns http success' do
      get '/test/master'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo commit patch' do
    it 'returns http success' do
      get '/test/commit/095955b.patch'
      expect(last_response.status).to eq(200)
    end

    it 'returns text/plain' do
      get '/test/commit/095955b.patch'
      expect(last_response.headers['Content-Type']).to match('text/plain.*')
    end
  end

  describe 'repo commit page' do
    it 'returns http success' do
      get '/test/commit/095955b'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo tag page' do
    it 'returns http success' do
      get '/test/tag/v0.0.3'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo tree page' do
    it 'returns http success' do
      get '/test/tree/master'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo tree page with path' do
    it 'returns http success' do
      get '/test/tree/master/examples'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo blob page with path' do
    it 'returns http success' do
      get '/test/blob/master/Gemfile'
      expect(last_response.status).to eq(200)
    end
  end

  describe 'repo blob raw page' do
    it 'returns http success' do
      get '/test/raw/master/Gemfile'
      expect(last_response.status).to eq(200)
    end

    it 'returns text/plain' do
      get '/test/raw/master/Gemfile'
      expect(last_response.headers['Content-Type']).to match('text/plain.*')
    end
  end

  describe 'repo log page' do
    it 'returns http success' do
      get '/test/master/page/1'
      expect(last_response.status).to eq(200)
    end
  end
end
