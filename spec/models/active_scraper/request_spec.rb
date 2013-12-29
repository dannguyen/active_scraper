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
        expect(@params[:is_obfuscated]).to be_false
      end

      it 'also works with a Addressable::URI' do
        req_params = Request.build_request_params Addressable::URI.parse(@url)
        expect(req_params)[:host].to eq 'www.example.com'
      end




      describe 'options argument' do
        before do
          @url = 'http://example.com/path?user=dan&password=helloworld'
        end

        describe ':obfuscate_query' do        
          context 'key is just a key' do       
            before do
              @req_params = Request.build_request_params @url, { obfuscate_query: [:password] }
            end

            it 'should omit the actual value for the given key in @params[:query] with __OMIT__' do
              expect(@req_params[:query]).to eq "user=dan&password=__OMIT__"
            end

            it 'should set :is_obfuscated to true' do
              expect(@req_params[:is_obfuscated]).to be_true
            end
          end

          context 'key is an Array' do
            before do
              @req_params = Request.build_request_params @url, { obfuscate_query: [:password, 4] }
            end

            it 'should replace actual value with __OMIT_[last n characters]__' do
              expect(@req_params[:query]).to eq "user=dan&password=__OMIT__orld"
            end
          end
        end
      end
    end
  
    describe '.create_from_uri' do
      context 'arguments' do
        it 'should take in a string' do 
          @req = Request.create_from_uri("http://example.com")
          expect(@req.host).to eq 'example.com'
        end

        it 'should take in a URI' do
          @req = Request.create_from_uri(URI.parse 'http://example.com')
          expect(@req.host).to eq 'example.com'
        end
      end

      context 'return value' do
        before do
          @req = Request.create_from_uri("http://example.com/path.html?query=helloworld")
        end

        it 'should return a ActiveScraper::Request object' do
          expect(@req).to be_a Request
          expect(@req.id).to be_present
        end

        it 'should set the appropriate attributes' do
          expect(@req.host).to eq 'example.com'
          expect(@req.path).to eq 'path.html'
          expect(@req.query).to eq 'query=helloworld'
          expect(@req.extname).to eq '.html'
          expect(@req).not_to be_obfuscated
        end
      end
    end


    describe '.create_and_fetch_response' do
      context 'arguments' do
        it 'accepts the same two arguments as .build_request_params'
        it 'accepts an optional third argument for a Fetcher instance'
      end

      context 'using Fetcher' do
        before do
          @url = 'http://example.com'
          @f = Fetcher.new
          @f.stub(:get_fresh)
        end
        it 'invokes Fetcher#get_fresh to get a response' do

          pending 'create a webmock'
          expect(@f).to receive(:get_fresh).with Addressable::URI
        end
      end

      it 'creates a new Request'
      it 'creates a new Response'
      it 'relates the request to the response'


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
        @req = Request.create_from_uri('http://example.com/path')
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


  context 'instance' do

    context 'attributes' do
      describe ':is_obfuscated' do        
        it 'should be set on after_save'
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