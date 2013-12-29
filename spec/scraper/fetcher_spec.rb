require 'spec_helper'

describe ActiveScraper::Fetcher do

  describe 'initialization' do
    it 'initializes without necessary args' do
      expect(ActiveScraper::Fetcher.new).to be_a ActiveScraper::Fetcher
    end
  end


  describe 'unitary behavior' do
    before do
      @fetcher = ActiveScraper::Fetcher.new
    end

    describe 'delegation to cache and fresh fetchers' do
      context 'cached scrape does not exist' do
        before do
          @fetcher.stub(:fetch_from_cache){ nil }
          @fetcher.stub(:fetch_fresh){ "fresh!" }
        end

        it 'delegates to #fetch_fresh' do  
          expect(@fetcher).to receive(:fetch_fresh).with('http://url.com', {})       
          @fetcher.fetch('http://url.com')
        end

        it 'returns with value of #fetch_fresh' do
          expect(@fetcher.fetch('http://url.com')).to eq 'fresh!'
        end
      end

      context 'cached scrape does exist' do
        before do
          @fetcher.stub(:fetch_from_cache){ 'cache!' }
        end

        it 'should return with value from cache' do
          expect(@fetcher.fetch('xx.com')).to eq 'cache!'
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
      it 'expects third argument to be Fetcher specific options'
    end

    describe 'Fetcher specific options' do
      describe ':last_fetched_by'
      describe ':http_method' do
        it 'is :get by default'
        it 'accepts :post'
      end


    end
  end

  describe 'integration' do

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


end