require 'spec_helper'

module ActiveScraper
  describe ActiveScraper::Cachework do

    before do 
      @url = 'http://example.com/path.html?q=hello'
      stub_request(:any, /.*example.*/)
      

      Timecop.travel(1.year.ago) do 
        ActiveScraper.create_request_and_fetch_response(@url)
        # diversion
      end

      @request = Request.first
      ## just a red herring that confirms latest_response is working
      @request.responses.create( ResponseObject::Basic.new(Response.first) )
    end

    it 'should be sane because i like redundant tests' do
      expect(Response.count).to eq 2
      expect(Response.first.request).to eq @request
    end

    describe '.find_cache_for_request' do 
      context 'when the request exists' do
        it 'returns corresponding latest_response' do
          expect( ActiveScraper.find_cache_for_request(@request) ).to eq @request.latest_response
        end

        it 'also works when :req argument is a String' do
          expect( ActiveScraper.find_cache_for_request(@url) ).to eq @request.latest_response
        end
      end

      context 'when request does not exist' do 
        it 'should return nil' do
          expect(ActiveScraper.find_cache_for_request(@url.chop)).to be_nil
        end
      end
    end


    context 'edge cases' do
      context 'Request exists, but has no Response' do        
        it 'should return nil' do
          Response.delete_all

          expect(ActiveScraper.find_cache_for_request(@request)).to be_nil
        end
      end

      context 'the Response exists but does not belong to Request' do                  
        it 'should still return nil' do
          Response.all.each{|r| r.update_attributes(request_id: 99)}
          expect(ActiveScraper.find_cache_for_request(@request)).to be_nil
        end
      end       
    end


  end
end