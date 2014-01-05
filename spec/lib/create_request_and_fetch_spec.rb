require 'spec_helper'


describe ActiveScraper::Request do
  describe 'Freshwork' do

    describe 'Request.get' do
      it 'returns an ResponseObject::Basic' do
      end

      it 'creates/uses a Request'
      it 'creates/uses a Response'

    end


    describe 'Request.post' do
      it 'invokes Fetcher with a :post' do

      end
    end

    describe 'ActiveScraper.create_request_and_fetch_response' do 
      context 'arguments' do
        before do
          @url = 'http://example.com/path.html?q=hello'
          stub_request(:any, /.*example.*/)
        end
        

        it 'returns a BasicObject containing .request and .response' do
          obj = ActiveScraper.create_request_and_fetch_response @url
          expect(obj.request).to eq Request.first
          expect(obj.response).to eq Response.first
        end

        it 'takes in same arguments as .build_from_uri' do   
          obj = ActiveScraper.create_request_and_fetch_response( @url, obfuscate_query: [:q])
          request = obj.request
          expect(request.query).to eq 'q=__OMIT__'
          expect(request.responses).not_to be_empty
        end

        it 'has optional 3rd argument for Fetcher' do
          fetcher = double(Fetcher.new)
          expect(fetcher).to receive(:fetch_fresh)

          ActiveScraper.create_request_and_fetch_response @url, {}, fetcher
        end

      end


      context 'simple GET request' do
        context 'its effects (end-to-end)' do
          before do
            @url = 'http://example.com/path.html?q=hello'

            VCR.use_cassette('example_create_and_fetch') do
              @created_obj = ActiveScraper.create_request_and_fetch_response @url            
              @request = @created_obj.request
              @request.reload
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
              @response = @created_obj.response
            end

            it 'creates a new Response' do
              expect(@response.id).to be_present
            end


            it 'relates the request to the response' do 
              expect(@response.request).to eq @request
            end

            it 'should have last_fetched_at set to Response#created_at' do
              expect(@request.last_fetched_at).to eq @response.created_at
            end
            
            context 'response already exists' do
              it 'should not create a new response'
            end
          end
        end

        describe 'the messages sent to Fetcher' do
          before do
            @url = 'http://example.com/'
            stub_request(:any, @url)            
          end        

          context 'this is an entirely new request' do
            it 'sends to :fetch_fresh' do
              @f = double(Fetcher.new)            

              @f.stub(:fetch_fresh)
              expect(@f).to receive(:fetch_fresh)

              ActiveScraper.create_request_and_fetch_response(@url, {}, @f)            
            end

            it 'does not attempt Fetcher#fetch_from_cache, which can accept a Request' do
              pending 'who cares? we just care if object is fresh? delete this test'
              @f.stub(:fetch)
              @f.stub(:fetch_fresh)
              @f.stub(:fetch_from_cache)
              expect(@f).not_to receive(:fetch_from_cache)

              ActiveScraper.create_request_and_fetch_response("http://example.com", {}, @f)            
            end

            it 'gets sent to Fetcher#get_fresh to get a response'  do
              pending 'who cares? we just care if object is fresh? delete this test'

              expect(@f).to receive(:fetch_fresh) do |uri|
                expect(uri).to be_a Addressable::URI
                expect(uri.to_s).to eq @url
              end

              ActiveScraper.create_request_and_fetch_response("http://example.com", {}, @f)
            end
          end

          context '@url exists as a Request' do
            before do
              @f = Fetcher.new
              @url = "http://example.com"
              @req = Request.create_from_uri(@url)
            end

            it 'sends Request record along to :fetch' do
              @f.stub(:fetch)
              expect(@f).to receive(:fetch).with(@req)

              ActiveScraper.create_request_and_fetch_response(@url, {}, @f)
            end

            it 'should not create a new Request record' do
              ActiveScraper.create_request_and_fetch_response(@url, {}, @f)
              expect(Request.count).to eq 1
            end
          end
        end
      end # GET



    end
  end

end