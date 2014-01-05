require 'spec_helper'


module ActiveScraper

 
  describe 'ActiveScraper.create_request_and_fetch_response' do 
    context 'arguments' do
      before do
        @url = 'http://example.com/path.html?q=hello'
        stub_request(:any, /.*example.*/)
      end
      
      it 'returns an object containing .request and .response' do
        obj = ActiveScraper.create_request_and_fetch_response @url
        expect(obj.request).to eq CachedRequest.first
        expect(obj.response).to eq CachedResponse.first
      end

      it 'takes in same arguments as .build_from_uri' do   
        obj = ActiveScraper.create_request_and_fetch_response( @url, obfuscate_query: [:q])
        request = obj.request
        expect(request.query).to eq 'q=__OMIT__'
        expect(request.responses).not_to be_empty
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

        context 'the returned object' do

          it 'has request and response and they are records' do
            expect(@created_obj.request).to be_an ActiveScraper::CachedRequest
            expect(@created_obj.response).to be_an ActiveScraper::CachedResponse
          end
        end

        context 'the request' do 
          it 'creates a new Request' do
            expect(CachedRequest.count).to eq 1
          end

          it 'returns a created Request' do
            expect(@request).to be_a ActiveScraper::CachedRequest
          end

          it 'attaches a Response to the Request' do
            expect(@request.responses.count).to eq 1
            resp = @request.responses.first

            expect(resp).to be_a ActiveScraper::CachedResponse
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

      describe 'the messages sent' do
        before do
          @url = 'http://example.com/'
          stub_request(:any, @url)            
        end        


        context '@url exists as a Request' do
          before do
            @url = "http://example.com"
            @req = CachedRequest.create_from_uri(@url)
          end


          it 'should not create a new Request record' do
            ActiveScraper.create_request_and_fetch_response(@url, {})
            expect(CachedRequest.count).to eq 1
          end
        end


        context 'the Response exists' do
          before do
            @url = 'http://example.com/path.html?q=hello'
            stub_request(:any, /.*example.*/)
            @req = CachedRequest.create_from_uri(@url)
            @resp = @req.responses.create  ResponseObject::Basic.new( HTTParty.get(@url) )
            @obj = ActiveScraper.create_request_and_fetch_response(@url)

            @response = @obj.response
          end


          it 'should not create a new Response' do
            expect(CachedResponse.count).to eq 1
          end

          it 'should return the existing requests latest response' do
            expect(@response).to eq @req.latest_response
          end
        end

      end
    end # GET



  end

end