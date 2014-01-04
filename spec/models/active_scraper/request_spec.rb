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

      it 'should set scheme' do
        expect(@params[:scheme]).to eq 'http'
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

      context 'the normalization of query params' do
        context 'is enabled by default' do
          describe '.normalize_query_params' do
            context 'the query is a string' do
              it 'should alphabetize them' do 
                nquery = Request.normalize_query_params("id=99&apple=42")
                expect(nquery).to eq 'apple=42&id=99'
              end

              it 'should preserve array' do
                pending ' this is failing, wait for resolution of HTTParty issue' 
                nquery = Request.normalize_query_params("apple=42&id=99&apple=10")
                expect(nquery).to eq 'apple=42&apple=10&id=99'
              end
            
              it 'should save blank keys' do
                nquery = Request.normalize_query_params("cat=&dog=&goat=")
                expect(nquery).to eq "cat=&dog=&goat="
              end

              it 'should remove non-used keys' do
                nquery = Request.normalize_query_params("cat&dog=2&goat&hat")
                expect(nquery).to eq 'dog=2'
              end
            end
          end
        end

        context 'as executed by .build_request_params' do
          before do
            @url = "http://www.example.com/?zeta=10&alpha=42"
          end

          it 'normalizes params by default' do
            r = Request.build_request_params(@url)
            expect(r[:query]).to eq 'alpha=42&zeta=10'
          end

          it 'can be disabled via options[:normalize_query] => false' do
            r = Request.build_request_params(@url, {:normalize_query => false} )
            expect(r[:query]).to eq 'zeta=10&alpha=42'
          end
        end
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
              expect(@req_params[:query]).to eq "password=__OMIT__&user=dan"
            end

            it 'should set :is_obfuscated to true' do
              expect(@req_params[:is_obfuscated]).to be_true
            end
          end

          context 'key is an Array' do

            it 'should replace actual value with __OMIT_[last n characters]__' do
              @req_params = Request.build_request_params @url, { obfuscate_query: [[:password, 4]]}
              expect(@req_params[:query]).to eq "password=__OMIT__orld&user=dan"
            end

            it 'should work with double array' do
              @req_params = Request.build_request_params @url, { obfuscate_query: [[:password, 4], 'user'] }
              expect(@req_params[:query]).to eq "password=__OMIT__orld&user=__OMIT__"
            end
          end
        end
      end
    end
  
    describe '.build_from_uri' do
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
          @req = Request.build_from_uri("https://example.com/path.html?query=helloworld")
        end

        it 'should return a ActiveScraper::Request object' do
          expect(@req).to be_a Request
          expect(@req.id).not_to be_present
        end

        it 'should set the appropriate attributes' do
          expect(@req.scheme).to eq 'https'
          expect(@req.host).to eq 'example.com'
          expect(@req.path).to eq '/path.html'
          expect(@req.query).to eq 'query=helloworld'
          expect(@req.extname).to eq '.html'
          expect(@req).not_to be_obfuscated
        end
      end
    end

    describe '.build_validating_params' do
      it 'should be a hash with only the validating params' do
        params = Request.build_validating_params('http://example.com/path/?q=2')

        expect(params).to be_a Hash
        expect(params.keys).to include(:scheme, :host, :path, :query)
        expect(params.keys).not_to include(:is_obfuscated, :extname)
      end
    end

    describe '.create_and_fetch_response' do

      context 'arguments' do
        it 'accepts the same two arguments as .build_request_params' 
        it 'accepts an optional third argument for a Fetcher instance'
      end

      context 'integration using Fetcher'
      # see integration for how it works with fetcher

    end

    context 'request already exists' do
      it 'does not create a new Request/Response'

    end
  end



  end

  describe 'scopes' do
    describe '.with_url' do
      before do
        @req = Request.create_from_uri('http://example.com/path')
      end

      it 'should scope by normalized uri' do
        expect(Request.with_url('http://EXAMPLE.com/path').first).to eq @req
      end

      it 'should return nil if any semantic part has changed' do
        expect(Request.with_url('http://example.com/path/')).to be_empty
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
    before do
      @request = Request.build_from_uri 'http://example.com'
      @request.responses.build({body: 'x'})
      @request.responses.build({body: 'x'})

      @request.save
    end
 
    it 'should be a has_many' do
      expect(@request.responses.count).to eq 2
    end

    it 'should be dependent:destroy' do
      @request.destroy
      expect(Response.count).to eq 0
    end

    describe '#latest_response' do
      it 'should be latest by created_at' do
        expect(@request.latest_response.id).to eq 2
      end

      describe 'convenience methods' do
        describe 'last_fetched_at' do
          it 'delegates to #latest created_at'
        end
      end


    end
  end


  context 'instance' do
    context 'validations' do 
      before do
        @req = Request.create_from_uri 'http://example.com/path/index.html&q=2001&r=hey'
      end

      it 'requires unique path, host, and index' do
        Request.create_from_uri 'http://example.com/path/index.html&q=2001&r=hey'
        expect( Request.count).to eq 1
      end

      it 'does care about scheme' do
        Request.create_from_uri 'https://example.com/path/index.html&q=2001&r=hey'
        expect( Request.count).to eq 2
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
      it 'should return a Adressable::URI' do
        @req = Request.build_from_uri 'http://example.com?q=z'
        expect(@req.uri).to be_a Addressable::URI
        expect(@req.uri.query).to eq 'q=z'
      end
    end

    describe 'obfuscated?' do
      it 'is true if :is_obfuscated is true'
    end

    describe 'executable?' do
      it 'should return true unless it is #obfuscated?'
    end
  end


end