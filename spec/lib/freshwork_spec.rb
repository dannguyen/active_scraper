require 'spec_helper'

module ActiveScraper
  describe ActiveScraper::Freshwork do

    it 'should respond to :get' do
      expect(ActiveScraper).to respond_to(:get)
    end

    it 'should respond to :post' do
      expect(ActiveScraper).to respond_to(:post)
    end
  end


  describe 'ActiveScraper.get' do
    before do
      @url = 'http://www.example.com'
      @response = ActiveScraper.get(@url)
    end

    context 'the front-end' do
      it 'returns a ActiveScraper::Response' do
        expect(@response).to be_a ActiveScraper::Response
        expect(@response).to be_a HTTParty::Response
      end
    end

    context 'the backend' do 
      it 'creates/uses a CachedRequest' do 
        expect(CachedRequest.count).to eq 1
      end
      
      it 'creates/uses a CachedResponse' do
        expect(CachedResponse.count).to eq 1
      end
    end
  end


  describe 'ActiveScraper.post' do
    it 'invokes Fetcher with a :post' do

    end
  end





end