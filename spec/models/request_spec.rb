require 'spec_helper'

describe ActiveScraper::Request do
  describe 'class method conveniences' do 
    describe '.build_request_params' do
      before do
        @url = "http://www.EXAMPLE.com/somewhere/file.json?id=99"
        @options = {}
      
        @params = ActiveScraper::Request.build_request_params(@url, @options)
      end

      it 'should set normalized host' do
        expect(@params[:host]).to eq 'www.example.com'
      end

      it 'should set path' do
        expect(@params[:path]).to eq '/somewhere/file.json'
      end

      it 'should set :query' do
        expect(@params[:query]).to eq 'id=99'
      end

      it 'should set extname' do
        expect(@params[:extname]).to eq '.json'
      end
    end
  

    describe '.create_from_uri' do
      it 'should take in a string' do 
        pending
        @req = ActiveScraper::Request.create_from_uri("http://example.com")
        expect(@req.host).to eq 'example.com'
      end

      it 'should take in a URI' do
        pending
        @req = ActiveScraper::Request.create_from_uri(URI.parse 'http://example.com')
        expect(@req.host).to eq 'example.com'
      end
    end
  end




  describe 'scopes' do
    describe '.with_uri' do
      before do
        @req = Request.create_from_uri('http://example.com/path')
      end

      it 'should scope by normalized uri' do
        pending
        expect(Request.with_uri('http://EXAMPLE.com/path')).to eq @req
      end

      it 'should return nil if any semantic part has changed' do
        pending
        expect(Request.with_uri('http://example.com/path/')).to be_nil
      end
    end
  end


  describe 'relationship to ActiveScraper::Response' do
    it 'should be a has_many'
    it 'should be dependent:destroy'
  end

end