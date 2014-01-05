require 'spec_helper'

module ActiveScraper
  describe 'find_or_build_response' do

    before do 
      @url = 'http://example.com/path.html?q=hello'
      stub_request(:any, /.*example.*/)
      

      Timecop.travel(1.year.ago) do 
        ActiveScraper.create_request_and_fetch_response(@url)
        # diversion
      end

      @request = CachedRequest.first
      ## just a red herring that confirms latest_response is working
      @request.responses.create( ResponseObject::Basic.new(CachedResponse.first) )
    end

    it 'should be sane because i like redundant tests' do
      expect(CachedResponse.count).to eq 2
      expect(CachedResponse.first.request).to eq @request
    end

    describe '.find_or_build_response' do 
      context 'when the request exists' do

        it 'raises an ArgumentError if not given a cached_request' do
          expect{ActiveScraper.find_or_build_response(URI.parse 'http://uri.com')}.to raise_error ArgumentError
        end

        it 'returns corresponding latest_response' do
          expect( ActiveScraper.find_or_build_response(@request) ).to eq @request.latest_response
        end

      end
    end


    context 'edge cases' do
      context 'Request exists, but has no Response' do        
        it 'should return nil' do
          pending 'this doesnt work because of activerecord caching'
          CachedResponse.delete_all
          expect(ActiveScraper.find_or_build_response(@request)).to be_nil
        end
      end

      context 'the Response exists but does not belong to Request' do                  
        it 'should still return nil' do
                    pending 'this doesnt work because of activerecord caching'
          CachedResponse.all.each{|r| r.update_attributes(cached_request_id: 99)}
          expect(ActiveScraper.find_or_build_response(@request)).to be_nil
        end
      end       
    end


  end
end