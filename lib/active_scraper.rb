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

    if request.id.nil? 
      # this request is new
      # so skip to the fresh
      resp = fetcher.fetch_fresh request 
    else 
      # will check the cache and the fresh
      resp = fetcher.fetch request
    end

    # build the response
    response = request.responses.build(resp)
    # theoretically, response will be saved too
    request.save 
         
    obj = Hashie::Mash.new(request: request, response: response)

    return obj
  end



end
