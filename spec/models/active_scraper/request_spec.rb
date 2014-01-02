require 'spec_helper'

describe ActiveScraper::Request do
  describe 'class method conveniences' do 
    describe '.build_request_params' do
      before do
        @url = "http://www.EXAMPLE.com/somewhere/file.json?id=99"
         
        @params = ActiveScraper::Request.build_request_params(@url)
      end

      it 'should set normalized host' do
        expect(@params[:host]).to eq 'www.example.com'
      end

      it 'should set path' do
        expect(@params[:path]).to eq '/somewhere/file.json'
      end

      it 'should set :query' do
        expect(@params[:query]).to eq 'id=99'
      end

      it 'should set extname' do
        expect(@params[:extname]).to eq '.json'
      end

      it 'should set :is_obfuscated to false by default' do
        expect(@params[:is_obfuscated]).to eq false
      end

      it 'also works with a Addressable::URI' do
        req_params = Request.build_request_params Addressable::URI.parse(@url)
        expect(req_params[:host]).to eq 'www.example.com'
      end




      describe 'options argument' do
        before do
          @url = 'http://example.com/path?user=dan&password=helloworld'
        end

        describe ':obfuscate_query' do        
          context 'key is just a key' do       
            before do
              @req_params = Request.build_request_params @url, { obfuscate_query: :password }
            end

            it 'should omit the actual value for the given key in @params[:query] with __OMIT__' do
              expect(@req_params[:query]).to eq "user=dan&password=__OMIT__"
            end

            it 'should set :is_obfuscated to true' do
              expect(@req_params[:is_obfuscated]).to be_true
            end
          end

          context 'key is an Array' do

            it 'should replace actual value with __OMIT_[last n characters]__' do
              @req_params = Request.build_request_params @url, { obfuscate_query: [[:password, 4]]}
              expect(@req_params[:query]).to eq "user=dan&password=__OMIT__orld"
            end

            it 'should work with double array' do
              @req_params = Request.build_request_params @url, { obfuscate_query: [[:password, 4], 'user'] }
              expect(@req_params[:query]).to eq "user=__OMIT__&password=__OMIT__orld"
            end
          end
        end
      end
    end
  
    describe '.build_from_uri', focus: true do
      context 'arguments' do
        it 'should take in a string' do 
          @req = Request.build_from_uri("http://example.com")
          expect(@req.host).to eq 'example.com'
        end

        it 'should take in a URI' do
          @req = Request.build_from_uri(URI.parse 'http://example.com')
          expect(@req.host).to eq 'example.com'
        end
      end

      context 'Request already exists' do
        before do
          @req = Request.build_from_uri(URI.parse 'http://example.com')
          @req.save
        end

        it 'should retrieve existing request' do
          expect(Request.count).to eq 1
          same_req = Request.build_from_uri(URI.parse 'http://example.com')
          same_req.save

          expect(Request.count).to eq 1
        end
      end

      context 'return value' do
        before do
          @req = Request.build_from_uri("http://example.com/path.html?query=helloworld")
        end

        it 'should return a ActiveScraper::Request object' do
          expect(@req).to be_a Request
          expect(@req.id).not_to be_present
        end

        it 'should set the appropriate attributes' do
          expect(@req.host).to eq 'example.com'
          expect(@req.path).to eq '/path.html'
          expect(@req.query).to eq 'query=helloworld'
          expect(@req.extname).to eq '.html'
          expect(@req).not_to be_obfuscated
        end
      end
    end


    describe '.create_and_fetch_response', focus: true do
      context 'arguments' do
        it 'accepts the same two arguments as .build_request_params' do

        end

        it 'accepts an optional third argument for a Fetcher instance'
      end

      context 'simple GET request' do
        context 'integration using Fetcher' do
          before do
            @url = 'http://example.com'
            @f = Fetcher.new
            @f.stub(:get_fresh)
          end

          it 'invokes Fetcher#get_fresh to get a response' do

          pending 'create a webmock'
            Request.create_and_fetch_response("http://example.com")
            expect(@f).to receive(:get_fresh).with "http://example.com"
          end
        end

        it 'creates a new Request'
        it 'creates a new Response'
        it 'relates the request to the response'
      end
    end

    context 'request already exists' do
      it 'does not create a new Request/Response'

    end
  end



  describe 'relationship to responses' do
    it 'is a has_many'

    describe '#latest' do
      it 'has_one #latest'
    end

    describe 'incomplete' do
      it 'is incomplete if no response exists'
    end


    describe 'dependent=>destroy' do
      it 'destroys all dependent responses'
    end
  end

  describe 'convenience methods' do
    describe 'last_fetched_at' do
      it 'delegates to #latest created_at'
    end

  end

  describe 'scopes' do
    describe '.with_uri' do
      before do
        @req = Request.build_from_uri('http://example.com/path')
      end

      it 'should scope by normalized uri' do
        pending
        expect(Request.with_uri('http://EXAMPLE.com/path')).to eq @req
      end

      it 'should return nil if any semantic part has changed' do
        pending
        expect(Request.with_uri('http://example.com/path/')).to be_nil
      end

      describe 'options argument is similar to build_request_params' do 
        describe ':obfuscate_query' do
          context 'request contains an obfuscated/omitted query value' do 
            it 'should still be included in this scope'
          end
        end
      end
    end


    describe 'last_fetched_by' do
      it 'returns responses with created_at >= given date'
    end
  end


  describe 'relationship to ActiveScraper::Response' do
    it 'should be a has_many'
    it 'should be dependent:destroy'
  end


  context 'instance', focus: true do
    context 'validations' do 
      before do
        @req = Request.create_from_uri 'http://example.com/path/index.html&q=2001&r=hey'
      end

      it 'requires unique path, host, and index' do
        Request.create_from_uri 'http://example.com/path/index.html&q=2001&r=hey'
        expect( Request.count).to eq 1
      end

      it 'does not care about scheme' do
        Request.create_from_uri 'https://example.com/path/index.html&q=2001&r=hey'
        expect( Request.count).to eq 1
      end


      it 'will allow new Request if query is in different order' do
        Request.create_from_uri 'https://example.com/path/index.html?r=hey&q=2001'
        expect( Request.count).to eq 2
      end
     
    end

    context 'attributes' do
      describe ':is_obfuscated' do        
        it 'should be set even before save action' do
          # this is quirkiness via the build_from_uri factory

          @req = Request.build_from_uri 'http://example.com?privateq=yo', obfuscate_query: [:privateq] 
          expect(@req.is_obfuscated).to be_true
          @req.save 
          expect(@req).to be_obfuscated
        end
      end
    end

    describe '#uri' do
      it 'should return a Adressable::URI'
    end

    describe 'obfuscated?' do
      it 'is true if :is_obfuscated is true'
    end

    describe 'executable?' do
      it 'should return true unless it is #obfuscated?'
    end
  end


end