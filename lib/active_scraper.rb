require "active_scraper/engine"
require 'active_scraper/response_object'
require 'active_scraper/fetcher'
require "active_scraper/cachework"
require "active_scraper/freshwork"

module ActiveScraper
  extend ActiveScraper::Cachework
  extend ActiveScraper::Freshwork


  # TODO: probably should be moved into another module
  def self.create_request_and_fetch_response(uri, opts={}, fetcher = nil)
    request = Request::find_or_build_from_uri(uri, opts)
    fetcher = fetcher || Fetcher.new

    if resp = ActiveScraper.find_cache_for_request(request)
      # this request already exists and so does its response
      # TODO: This is weird, because Fetcher uses ActiveScraper.find_cache_for_request
       #  so something here is redundant...
      is_fresh = false
      response = resp
    else
      # this request may/may not exist, but it doesn't have a response,
      #  so skip to the fresh
      is_fresh = true
      resp = fetcher.fetch_fresh( request )       
      response = request.responses.build(resp)
      request.save      
    end

     
         
    obj = Hashie::Mash.new(request: request, response: response, :fresh? => is_fresh )

    return obj
  end



end
