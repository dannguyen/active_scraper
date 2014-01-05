require 'spec_helper'

module ActiveScraper
  describe ActiveScraper::Cachework do

    before do 
      @url = 'http://example.com/path.html?q=hello'
      stub_request(:any, /.*example.*/)
      ActiveScraper.create_request_and_fetch_response(@url)

      @request = Request.first
      @response = Response.first

    end

    it 'should be sane' do
      expect(@response.request).to eq @request
    end

    describe '.find_cache_for_request' do 
      context 'when the request exists' do
        it 'returns corresponding latest_response'

        it 'also works when :req argument is a String'
      end

      context 'when request does not exist' do 
        it 'should return nil'
      end
    end


    context 'edge cases' do
      context 'Request exists, but has no Response' do
        it 'should return nil'
      end

      context 'the Response exists but does not belong to Request' do
        it 'should still return nil'
      end       
    end


  end
end