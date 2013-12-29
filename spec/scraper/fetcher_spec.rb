require 'spec_helper'

describe ActiveScraper::Fetcher do

  describe 'initialization' do
    it 'initializes without necessary args' do
      expect(ActiveScraper::Fetcher.new).to be_a ActiveScraper::Fetcher
    end
  end


  describe 'fetch' do
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
end