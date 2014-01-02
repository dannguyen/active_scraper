require 'spec_helper'


describe ActiveScraper::Request do
  describe 'with Fetcher' do
    describe 'Request.create_and_fetch_response' do 

      context 'simple GET request' do
        describe 'the messages sent to Fetcher' do
          before do
            @url = 'http://example.com/'
            @f = Fetcher.new
          end

          context 'this is an entirely new request' do
            it 'attempts Fetcher#fetch first, which can accept a Request' do
              @f.stub(:fetch)
              expect(@f).to_not receive(:fetch)

              Request.create_and_fetch_response("http://example.com", {}, @f)            
            end

            it 'goes directly to Fetcher#get_fresh to get a response'  do
              @f.stub(:fetch_fresh)

              expect(@f).to receive(:fetch_fresh) do |req|
                expect(req).to be_a ActiveScraper::Request
                expect(req.uri.to_s).to eq @url
              end

              Request.create_and_fetch_response("http://example.com", {}, @f)
            end
          end

          context '@url exists as a request' do
            before do
              @req = Request.create_from_uri(@url)
              @f.stub(:fetch)
            end

            it 'sends to :fetch' do
              expect(@f).to receive(:fetch).with(@req)
              Request.create_and_fetch_response("http://example.com", {}, @f)
            end

            it 'should not create a new request' do
              Request.create_and_fetch_response("http://example.com", {}, @f)
              expect(Request.count).to eq 1
            end
          end
        end

        it 'creates a new Request'
        it 'creates a new Response'
        it 'relates the request to the response'

        context 'response already exists' do
          it 'should not create a new response'

        end


      end

    end
  end

end