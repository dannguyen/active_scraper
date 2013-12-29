require 'spec_helper'

module ActiveScraper
  describe Response do
    describe '.build_from_response_object' do
      context 'given a regular HTTParty-like object' do
        before do
          @url = "http://www.hello.world.example.com"
          # set up webmock
          @response = Response.build_from_response_object(@obj)
        end

        it 'should be a Response record' do
          expect(@response).to be_a ActiveScraper::Response
        end

        it 'should save content_type' do
          expect(@response.content_type).to eq @obj.content_type
        end

        it 'should save body' do
          expect(@response.body).to eq @obj.body
        end

        it 'should save headers as a serialized Hash' do
          expect(@response.headers).to be_a Hash
          expect(@response.headers['Server']).to eq 'Apache'
        end
      end
    end

    context 'attributes' do 
      describe ':checksum' do
        before do
          @response = Response.create(body: "x", headers: {'Server' => 'Apache'})
        end
        it 'should set checksum after save' do
          expect(@response.checksum).to eq 'x'.hash
        end
      end

      describe ':headers' do
        it 'should be a serialized hash' do
          expect(@response.headers['Server'].to eq 'Apache')
        end
      end
    end
  end
end
