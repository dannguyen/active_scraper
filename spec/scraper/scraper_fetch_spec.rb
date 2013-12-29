require 'spec_helper'

describe ActiveScraper::Scraper do

  describe 'initialization' do
    it 'initializes without necessary args' do
      expect(ActiveScraper::Scraper.new).to be_a ActiveScraper::Scraper
    end
  end


  describe 'fetch' do
    before do
      @scraper = ActiveScraper::Scraper.new
    end

    describe 'delegation to cache and fresh fetchers' do
      context 'cached scrape does not exist' do
        before do
          @scraper.stub(:fetch_from_cache){ nil }
          @scraper.stub(:fetch_fresh){ "fresh!" }
        end

        it 'delegates to #fetch_fresh' do  
          expect(@scraper).to receive(:fetch_fresh).with('http://url.com', {})       
          @scraper.fetch('http://url.com')
        end

        it 'returns with value of #fetch_fresh' do
          expect(@scraper.fetch('http://url.com')).to eq 'fresh!'
        end
      end

      context 'cached scrape does exist' do
        before do
          @scraper.stub(:fetch_from_cache){ 'cache!' }
        end

        it 'should return with value from cache' do
          expect(@scraper.fetch('xx.com')).to eq 'cache!'
        end
      end
    end
  end
end