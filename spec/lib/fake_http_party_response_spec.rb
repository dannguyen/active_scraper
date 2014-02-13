require 'spec_helper'

module ActiveScraper
  describe ActiveScraper::FakeHTTPartyResponse do

    before do 
      @url = 'http://example.com/path.html?q=hello'
      stub_request(:get, @url).to_return( 
        :body => "goodbye", :headers => { 'content-length' => 7, 'content-type'=>'text/html', "server"=>'Apache' }
      )
      obj = ActiveScraper.create_request_and_fetch_response(@url)
 
      @cached_request = obj.request
      @cached_response = obj.response
      @actual_httparty_response = HTTParty.get(@url)
      @response = ActiveScraper::FakeHTTPartyResponse.new(@cached_request, @cached_response)
    end


    context 'quacking like a HTTParty::Response' do
      it 'should have body and to_s be the same' do
        expect(@response.to_s).to eq 'goodbye'
        expect(@response.body).to eq 'goodbye'

        expect(@response.body).to eq @actual_httparty_response.body
      end

      it 'should have the right code' do
        expect(@response.code).to eq 200
        expect(@response.code).to eq @actual_httparty_response.code
        
      end

      context 'has a request-like object' do 
        before do 
          @party_request = @actual_httparty_response.request
          @duck_request = @response.request
        end
        it 'should fake an options hash' do
          expect(@duck_request.options).to be_a Hash
        end

        it 'should have :uri' do
          expect(@duck_request.uri).to be_a URI::HTTP
          expect(@duck_request.uri.to_s).to eq @party_request.uri.to_s
        end
      end



    end
  end
end