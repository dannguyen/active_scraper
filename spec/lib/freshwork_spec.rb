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

    it 'returns a ActiveScraper::Response' do
      expect(@response).to be_a ActiveScraper::Response
    end

    it 'creates/uses a Request'
    it 'creates/uses a Response'

  end


  describe 'ActiveScraper.post' do
    it 'invokes Fetcher with a :post' do

    end
  end





end