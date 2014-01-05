require 'spec_helper'

module ActiveScraper
  describe ResponseObject::Basic do

    before do
      @url = 'http://example.com'
      @response_hash = {:body => "abc", :status => 200, :headers => {'Content-Type' => 'text/html', 'Server' => 'Apache', 'Content-Length' => 3 }}

      stub_request(:get, 'http://example.com').to_return(@response_hash)        
    end

    context 'instance' do
      before do 
        @response = ResponseObject::Basic.new HTTParty.get(@url)
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
        r = ResponseObject::Basic.new(HTTParty.get(@url))
        expect(r.body).to eq 'abc'
        expect(r.headers['server']).to eq 'Apache'
        expect(r.code).to eq 200
      end


      it 'converts Net::HTTPResponse' do
        r = ResponseObject::Basic.new(Net::HTTP.get_response(URI(@url)))
        expect(r.body).to eq 'abc'
        expect(r.headers['server']).to eq 'Apache'
        expect(r.code).to eq 200
      end


      it 'converts OpenURI::StringIO' do
        require 'open-uri'
        r = ResponseObject::Basic.new(open(@url))
        expect(r.body).to eq 'abc'
        expect(r.headers['server']).to eq 'Apache'
        expect(r.code).to eq 200
      end

      it 'converts ActiveScraper::Response' do
        r = ResponseObject::Basic.new ActiveScraper::Response.create(body: 'abc', code: 200, headers: @response_hash[:headers])
        expect(r.body).to eq 'abc'
        expect(r.headers['Server']).to eq 'Apache' ## Does not actively lower-case header keys
        expect(r.code).to eq 200
      end

      it 'raises error otherwise' do
        expect{ ResponseObject::Basic.new(['hi there'])}.to raise_error ArgumentError
      end
    end


    describe ResponseObject::Fetched do
      it 'is a subclass of Basic' do
        expect(ResponseObject::Fetched < ResponseObject::Basic).to be_true
      end

      context 'class factory and fresh?' do
        describe '.from_fresh' do
          it 'should be fresh?' do
            f = ResponseObject::Fetched.from_fresh HTTParty.get(@url)
            expect(f).to be_fresh
          end
        end
        
        describe '.from_cache' do
          it 'should not be #fresh?' do
            f = ResponseObject::Fetched.from_cache HTTParty.get(@url)
            expect(f).not_to be_fresh
          end
        end
      end
    end



  end
end