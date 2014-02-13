require 'spec_helper'

describe ActiveScraper::CachedRequest do
  describe 'class method conveniences' do 
    
  
    describe '.build_from_uri' do
      context 'arguments' do
        it 'should take in a string' do 
          @req = CachedRequest.build_from_uri("http://example.com")
          expect(@req.host).to eq 'example.com'
        end

        it 'should take in a URI' do
          @req = CachedRequest.build_from_uri(URI.parse 'http://example.com')
          expect(@req.host).to eq 'example.com'
        end
      end

      context 'CachedRequest already exists' do
        before do
          @req = CachedRequest.build_from_uri(URI.parse 'http://example.com')
          @req.save
        end

        it 'should retrieve existing request' do
          expect(CachedRequest.count).to eq 1
          same_req = CachedRequest.build_from_uri(URI.parse 'http://example.com')
          same_req.save

          expect(CachedRequest.count).to eq 1
        end
      end

      context 'return value' do
        before do
          @req = CachedRequest.build_from_uri("https://example.com/path.html?query=helloworld")
        end

        it 'should return a ActiveScraper::CachedRequest object' do
          expect(@req).to be_a CachedRequest
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
        params = CachedRequest.build_validating_params('http://example.com/path/?q=2')

        expect(params).to be_a Hash
        expect(params.keys).to include(:scheme, :host, :path, :query)
        expect(params.keys).not_to include(:is_obfuscated, :extname)
      end
    end
  end

  describe 'unobfuscated_query' do 
    it 'should have a temporary @unobfuscated_query attr_readable'

  end

  describe 'scopes' do
    describe '.with_url / .matching_request' do
      before do
        @req = CachedRequest.create_from_uri('http://example.com/path')
      end

      it 'should scope by normalized uri' do
        expect(CachedRequest.with_url('http://EXAMPLE.com/path').first).to eq @req
      end

      it 'should return nil if any semantic part has changed' do
        expect(CachedRequest.with_url('http://example.com/path/')).to be_empty
      end


      it 'should accept a ActiveScraper::CachedRequest as argument' do
        expect(CachedRequest.with_url(@req).first).to eq @req
        expect(CachedRequest.matching_request(@req).first).to eq @req
      end

      describe 'options argument is similar to build_request_params' do 
        describe ':obfuscate_query' do
          context 'request contains an obfuscated/omitted query value' do 
            it 'should still be included in this scope' do
              pending "is this needed"
            end
          end
        end
      end
    end


    describe 'last_fetched_before' do
      it 'returns requests with responses that were created_at BEFORE given date' do

        Timecop.travel(10.days.ago) do
          @request_a = CachedRequest.create_from_uri 'http://a.com'
          @request_b = CachedRequest.create_from_uri 'http://b.com'
          ActiveScraper::CachedResponse.create(cached_request_id: @request_a.id)
        end

        ActiveScraper::CachedResponse.create(cached_request_id: @request_b.id)

        expect(CachedRequest.last_fetched_before(5.days.ago)).to eq [@request_a]

      end
    end
  end


  describe 'relationship to ActiveScraper::CachedResponse' do
    before do
      @request = CachedRequest.build_from_uri 'http://example.com'
      @request.responses.build({body: 'x'})
      @request.responses.build({body: 'x'})
      @request.save
      @request.reload
    end
 
    it 'should be a has_many' do
      expect(@request.responses.count).to eq 2
    end

    it 'should be dependent:destroy' do
      @request.destroy
      expect(CachedResponse.count).to eq 0
    end

    describe '#latest_response' do
      it 'should be latest by created_at' do
        expect(@request.latest_response.id).to eq 2
      end

      describe 'last_fetched_at' do
        it 'is equal to @request#latest_response.created_at' do
          expect(@request.last_fetched_at).to eq @request.latest_response.created_at
        end
      end


    end
  end


  context 'instance' do
    context 'validations' do 
      before do
        @req = CachedRequest.create_from_uri 'http://example.com/path/index.html&q=2001&r=hey'
      end

      it 'requires unique path, host, and index' do
        CachedRequest.create_from_uri 'http://example.com/path/index.html&q=2001&r=hey'
        expect( CachedRequest.count).to eq 1
      end

      it 'does care about scheme' do
        CachedRequest.create_from_uri 'https://example.com/path/index.html&q=2001&r=hey'
        expect( CachedRequest.count).to eq 2
      end


      it 'will allow new CachedRequest if query is in different order' do
        CachedRequest.create_from_uri 'https://example.com/path/index.html?r=hey&q=2001'
        expect( CachedRequest.count).to eq 2
      end
     
    end

    context 'attributes' do
      describe ':is_obfuscated' do        
        it 'should be set even before save action' do
          # this is quirkiness via the build_from_uri factory

          @req = CachedRequest.build_from_uri 'http://example.com?privateq=yo', obfuscate_query: [:privateq] 
          expect(@req.is_obfuscated).to be_true
          @req.save 
          expect(@req).to be_obfuscated
        end
      end
    end

    describe '#uri' do
      it 'should return an Addressable::URI' do
        @req = CachedRequest.build_from_uri 'http://example.com?q=z'
        expect(@req.uri).to be_a Addressable::URI
        expect(@req.uri.query).to eq 'q=z'
      end
    end

    describe 'obfuscated?' do
      it 'is true if :is_obfuscated is true' do
        pending 'do we really need this?'
      end
    end

    describe 'executable?' do
      it 'should return true unless it is #obfuscated?'
    end
  end


end