require 'spec_helper'

describe ActiveScraper::Fetcher do

  describe 'initialization' do
    it 'initializes without necessary args' do
      expect(ActiveScraper::Fetcher.new).to be_a ActiveScraper::Fetcher
    end

    context 'can accept a Hash of options' do
      describe ':http_method' do
        it 'sets the http_method' do
          f = Fetcher.new(http_method: :post)
          expect(f.http_method).to eq :post
          expect(f.post?).to be_true
        end
        
        it 'is otherwise :get by default' do
          f = Fetcher.new
          expect(f.get?).to be_true 
        end
      end

      describe ':last_fetched_before' do
        it 'sets the last_fetched_by' do
          f = Fetcher.new(last_fetched_before: 10.days.ago)
          expect(f.last_fetched_before).to be_within(2).of 10.days.ago
        end

        it 'is beginning of time by default' do
          f = Fetcher.new
          expect(f.last_fetched_before).to eq Time.at(0)
        end
      end
    end
  end


  describe '#fetch' do
    before do
      @url = 'http://url.com'
      

      @fetcher = ActiveScraper::Fetcher.new
    end

    describe 'what it does based on cached records' do
      context 'when cached scrape does not exist' do
        before do
          stub_request(:any, @url).to_return(:body => "fresh!", :status => 200)
          @fetcher.stub(:perform_fresh_request){ HTTParty.get(@url)}
          @resp = @fetcher.fetch(@url)
        end

        it 'returns a ResponseObject' do  
          expect(@resp).to be_a ActiveScraper::ResponseObject::Fetched
        end

        it 'should be #fresh?' do
          expect(@resp).to be_fresh
        end

        it 'gets fresh body' do
          expect(@resp.body).to eq 'fresh!'
        end
      end

      context 'cached scrape does exist' do
        before do
          @fetcher.stub(:perform_cache_request){ ActiveScraper::CachedResponse.create(body: 'from cache!') }
          @cache_resp = @fetcher.fetch(@url)         
        end

        it 'should convert cache object into a ResponseObject::Fetched' do
          expect(@cache_resp).to be_a ActiveScraper::ResponseObject::Fetched
        end

        it 'gets fresh cache' do
          expect(@cache_resp.body).to eq 'from cache!'
        end

        it 'should not be #fresh?' do 
          expect(@cache_resp).not_to be_fresh
        end
      end
    end
  end


  context 'fetch arguments and options' do
    describe 'two arguments' do
      it 'expects first argument to be a URI/string'
      it 'expects second argument to be Fetcher specific options'
    end

    describe 'three arguments' do
      it 'expects first argument to be a URI/string'
      it 'expects second argument to be additional fetching hash options'
      it 'expects third argument to be Fetcher specific options' do
        pending 'need to write tests to show that this overrides Fetcher initialized settings'
      end
    end


  end

  # THESE TESTS ARE DUMB
  describe 'integration', skip: true do

    context 'with ActiveRecord store' do
      describe '#fetch_from_cache' do
        it 'always fetches latest response'
        it 'does not alter request'
        it 'returns nil if matching request is not found'
      end
    end

    describe 'convenience methods' do
      describe 'auto body accessors' do
        describe '#fetch_body' do
          it 'should return string'
        end

        describe '#fetch_parsed_body' do
          context ':response#content_type is text/html' do
            it 'should return Nokogiri::XML::Node'
          end

          context ':response#content_type is xml' do
            it 'should return Nokogiri::XML::Node'
          end

          context 'response#content_type is json' do
            it 'should return Array if applicable'
            it 'should return Hash'
          end

          context 'response#content_type is something else' do
            it 'should return a String'
          end
        end
      end
    end
  end


  context 'class methods' do
    describe '.build_from_response_object' do
      context 'obj is HTTParty::Response' do
        it 'should convert headers to_hash'
      end
      it 'should work with regular Net::HTTPResponse'
      it 'should return a blank object in other cases'
    end
  end

end