require 'spec_helper'

describe "functional scraping example" do

  context 'on first scrape' do
    
    it 'sees that no cached responses exist'
    it 'makes an actual HTTParty.get request'

    context 'GET request succeeds' do
      it 'saves a new Request'
      it 'saves a new Response belonging to Request'
    
      it 'returns a ActiveScraper::Response object'
      it 'returns a Nokogiri::XML::Document if call is made to #fetch_parsed_body'
    end
  end


  context 'on scrapes when cache is warm' do
    it 'returns a response'

  end


end