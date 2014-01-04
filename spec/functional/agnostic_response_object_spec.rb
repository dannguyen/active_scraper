require 'spec_helper'

module ActiveScraper
  describe AgnosticResponseObject do

    before do
      @url = 'http://example.com'
      @response_hash = {:body => "abc", :status => 200, :headers => {'Content-Type' => 'text/html', 'Server' => 'Apache', 'Content-Length' => 3 }}

      stub_request(:get, 'http://example.com').
                    to_return(
                      @response_hash
                    )        
    end

    context 'instance' do
      before do 
        @response = AgnosticResponseObject.new HTTParty.get(@url)
      end

      describe 'attributes' do
        it 'has a #body' do
          expect(@response.body).to eq 'abc'
        end

        it 'has a #code' do
          expect(@response.code).to eq 200
        end

        it 'has a #content_type' do
          expect(@response.content_type).to eq 'text/html'
        end

        it 'has #headers as a Hash' do
          expect(@response.headers).to be_a Hash
          expect(@response.headers).not_to be_empty
        end
      end

      it 'acts like a HashWithIndifferentHeaders' do
        expect(@response['headers']).to eq @response.headers
        expect(@response[:body]).to eq @response.body
      end
    end


    describe '#initialize' do


      it 'converts HTTParty::Response' do
        r = AgnosticResponseObject.new(HTTParty.get(@url))
        expect(r.body).to eq 'abc'
        expect(r.headers['server']).to eq 'Apache'
        expect(r.code).to eq 200
      end


      it 'converts Net::HTTPResponse' do
        r = AgnosticResponseObject.new(Net::HTTP.get_response(URI(@url)))
        expect(r.body).to eq 'abc'
        expect(r.headers['server']).to eq 'Apache'
        expect(r.code).to eq 200
      end


      it 'converts OpenURI::StringIO' do
        require 'open-uri'
        r = AgnosticResponseObject.new(open(@url))
        expect(r.body).to eq 'abc'
        expect(r.headers['server']).to eq 'Apache'
        expect(r.code).to eq 200
      end

      it 'converts ActiveScraper::Response' do
        r = AgnosticResponseObject.new ActiveScraper::Response.create(body: 'abc', code: 200, headers: @response_hash[:headers])
        expect(r.body).to eq 'abc'
        expect(r.headers['Server']).to eq 'Apache' ## Does not actively lower-case header keys
        expect(r.code).to eq 200
      end

      it 'raises error otherwise' do
        expect{ AgnosticResponseObject.new(['hi there'])}.to raise_error ArgumentError
      end
    end



  end
end