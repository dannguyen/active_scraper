require 'spec_helper'

module ActiveScraper
  describe CachedRequest do
    describe '.build_request_params' do
      before do
        @url = "http://www.EXAMPLE.com/somewhere/file.json?id=99"
         
        @params = ActiveScraper::CachedRequest.build_request_params(@url)
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
        req_params = CachedRequest.build_request_params Addressable::URI.parse(@url)
        expect(req_params[:host]).to eq 'www.example.com'
      end

      context 'the normalization of query params' do
        context 'is enabled by default' do
          describe '.normalize_query_params' do
            context 'the query is a string' do
              it 'should alphabetize them' do 
                nquery = CachedRequest.normalize_query_params("id=99&apple=42")
                expect(nquery).to eq 'apple=42&id=99'
              end

              it 'should preserve array' do
                pending ' this is failing, wait for resolution of HTTParty issue' 
                nquery = CachedRequest.normalize_query_params("apple=42&id=99&apple=10")
                expect(nquery).to eq 'apple=42&apple=10&id=99'
              end
            
              it 'should save blank keys' do
                nquery = CachedRequest.normalize_query_params("cat=&dog=&goat=")
                expect(nquery).to eq "cat=&dog=&goat="
              end

              it 'should remove non-used keys' do
                nquery = CachedRequest.normalize_query_params("cat&dog=2&goat&hat")
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
            r = CachedRequest.build_request_params(@url)
            expect(r[:query]).to eq 'alpha=42&zeta=10'
          end

          it 'can be disabled via options[:normalize_query] => false' do
            r = CachedRequest.build_request_params(@url, {:normalize_query => false} )
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
              @req_params = CachedRequest.build_request_params @url, { obfuscate_query: :password }
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
              @req_params = CachedRequest.build_request_params @url, { obfuscate_query: [[:password, 4]]}
              expect(@req_params[:query]).to eq "password=__OMIT__orld&user=dan"
            end

            it 'should work with double array' do
              @req_params = CachedRequest.build_request_params @url, { obfuscate_query: [[:password, 4], 'user'] }
              expect(@req_params[:query]).to eq "password=__OMIT__orld&user=__OMIT__"
            end
          end
        end
      end
    end


  end
end
