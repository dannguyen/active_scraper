require 'spec_helper'

module ActiveScraper

  describe 'ActiveScraper.get' do
    before do
      @url = 'http://www.example.com'
      @response_hash = {:body => "abc", :status => 200, :headers => {'Content-Type' => 'text/html', 'Server' => 'Apache', 'Content-Length' => 3 }}
      stub_request(:get, @url).to_return(@response_hash)        

      @response = ActiveScraper.get(@url)
    end

    context 'the front-end'  do
      it 'returns a ActiveScraper::Response' do
        expect(@response).to be_a ActiveScraper::Response
      end

      it 'acts like a HTTParty::Response' do
        expect(@response.to_s).to eq 'abc'
        expect(@response.body).to eq 'abc'
        expect(@response.code).to eq 200
        expect(@response.content_type).to eq 'text/html'
      end
    end

    context 'the backend' do 
      it 'creates/uses a CachedRequest' do 
        expect(@response.request.uri.to_s).to eq CachedRequest.first.uri.to_s
        expect(CachedRequest.count).to eq 1
      end
      
      it 'creates/uses a CachedResponse' do
        expect(@response.response.body).to eq CachedResponse.first.body
        expect(CachedResponse.count).to eq 1
      end
    end


    context 'another GET made, with no forcing a refresh' do
      it 'should not create a new CachedRequest or CachedResponse' do
        r = ActiveScraper.get(@url)
        expect(CachedResponse.count).to eq 1
        expect(CachedRequest.count).to eq 1
      end
    end
  end


  # DEPRECATE: we don't need post
  describe 'ActiveScraper.post', skip: true do
    before do
      @url = 'http://www.example.com/'
      stub_request(:post, @url).with( body: "please post").to_return({:body => "posted!", :status => 200})    

      @response = ActiveScraper.post(@url,  body: "please post")
    end

    it 'invokes Fetcher with a :post' do
      expect(@response.body).to eq "posted!"
    end
  end





end