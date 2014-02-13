# encoding: UTF-8

require "active_scraper/engine"
require 'active_scraper/fake_http_party_response'
require 'active_scraper/response_object'

module ActiveScraper


  # returns a ActiveScraper::CachedResponse
  def self.get(uri, options={})
    o = create_request_and_fetch_response(uri, options)

    return o.response
  end



  # delegates to CachedRequest::find_or_build_from_uri
  #   req (URI or String). If CachedRequest, is idempotent
  #   
  # returns a new or existing CachedRequest
  def self.find_or_build_request(req, opts={})
    CachedRequest.find_or_build_from_uri(req, opts)
  end

  ## cached_request (CachedRequest) => the request to find a response for
  ##
  ## returns a new or existing CachedResponse

  def self.find_or_build_response(cached_request, opts={})
    raise ArgumentError, "Only accepted CachedRequest, but was passed in a #{cached_request.class}" unless cached_request.is_a?(CachedRequest)
    opts = normalize_hash(opts)

    response = CachedResponse.find_cache_for_cached_request(cached_request, opts)

    if response.blank?
      fetched_obj = fetch_fresh(cached_request.uri, opts)
      response = CachedResponse.build_from_response_object(fetched_obj)
    end

    return response
  end


  def self.create_request_and_fetch_response(uri, opts={})
    opts = normalize_hash(opts)
    # first, find or build the request
    request = find_or_build_request(uri, opts)
    # then find or build a matching response
    response = find_or_build_response(request, opts)
    # associate and save the two
    request.responses << response
    request.save
     
    obj = Hashie::Mash.new(request: request, response: response)
    
    return obj
  end

  # Returns an object compatible with HTTParty, i.e. an ActiveScraper::FakeHTTPartyResponse
  # to be deprecated
  def self.build_usable_response(request, response)
    ActiveScraper::FakeHTTPartyResponse.new(request, response)
  end



  def self.fetch_fresh(url, opts={})
     resp = HTTParty.get(url, opts)

     return ActiveScraper::ResponseObject.factory(resp)
  end




  def self.normalize_hash(hsh)
    unless hsh.is_a?(HashWithIndifferentAccess)
      hsh = HashWithIndifferentAccess.new(hsh) 
    end

    return hsh
  end

end
