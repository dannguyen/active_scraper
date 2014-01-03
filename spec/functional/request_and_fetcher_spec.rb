require 'spec_helper'


describe ActiveScraper::Request do
  describe 'with Fetcher' do
    describe 'Request.create_and_fetch_response' do 

      context 'simple GET request' do
        context 'its effects (end-to-end)' do
          before do
            @url = 'http://example.com/path.html?q=hello'

            VCR.use_cassette('example_create_and_fetch') do              
              @request = Request.create_and_fetch_response @url
            end         
          end

          context 'the request' do 
            it 'creates a new Request' do
              expect(Request.count).to eq 1
            end

            it 'returns a created Request' do
              expect(@request).to be_a ActiveScraper::Request
            end

            it 'attaches a Response to the Request' do
              expect(@request.responses.count).to eq 1
              resp = @request.responses.first

              expect(resp).to be_a ActiveScraper::Response
              expect(resp.id).to be_present
            end
          end

          context 'the response' do
            before do
              @response = Response.last
            end

            it 'creates a new Response' do
              expect(@response.id).to be_present
            end


            it 'relates the request to the response' do 
              expect(@response.request).to eq @request
            end
            
            context 'response already exists' do
              it 'should not create a new response'
            end
          end
        end

        describe 'the messages sent to Fetcher' do
          before do
            @url = 'http://example.com/'
            @f = Fetcher.new
          end        

          context 'this is an entirely new request' do
            it 'attempts Fetcher#fetch first, which can accept a Request' do
              @f.stub(:fetch)
              expect(@f).to receive(:fetch)

              Request.create_and_fetch_response("http://example.com", {fresh: true}, @f)            
            end


            it 'does not attempt Fetcher#fetch_from_cache, which can accept a Request' do
              @f.stub(:fetch_fresh)
              @f.stub(:fetch_from_cache)
              expect(@f).not_to receive(:fetch_from_cache)

              Request.create_and_fetch_response("http://example.com", {fresh: true}, @f)            
            end

            it 'gets sent to Fetcher#get_fresh to get a response'  do
              @f.stub(:fetch_fresh)

              expect(@f).to receive(:fetch_fresh) do |uri|
                expect(uri).to be_a Addressable::URI
                expect(uri.to_s).to eq @url
              end

              Request.create_and_fetch_response("http://example.com", {fresh: true}, @f)
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
      end # GET



    end
  end

end