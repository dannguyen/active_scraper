require 'spec_helper'

module ActiveScraper
  describe Response do
    describe '.build_from_response_object' do
      context 'given a regular HTTParty-like object' do
        before do
          @url = "http://www.hello.world.example.com"
          stub_request(:get, @url).to_return( 
            :body => "abc", :headers => { 'content-length' => 3, 'content-type'=>'text/html', "server"=>'Apache' }
          )

          @resp_obj = Fetcher.build_response_object HTTParty.get(@url)
          # set up webmock
          @response = Response.build_from_response_object(@resp_obj)
        end

        it 'should be a Response record' do

          expect(@response).to be_a ActiveScraper::Response
        end

        it 'should save content_type' do
          expect(@response.content_type).to eq 'text/html'
        end

        it 'should save body' do
          expect(@response.body).to eq 'abc'
        end

        it 'should have a status code' do 
          expect(@response.code).to eq 200
        end

        it 'should save headers as a serialized Hash' do
          expect(@response.headers).to be_a Hash
          expect(@response.headers['server']).to eq 'Apache'
        end
      end
    end

    context 'attributes' do 
      before do
        @r = Response.create(body: "x", headers: {'Server' => 'Apache'})
      end

      it 'should set checksum during save process' do
        expect(@r.checksum).to eq 'x'.hash
      end

      it 'should be a serialized hash' do
        expect(@r.headers['Server']).to eq 'Apache'
      end

    end
  end
end
