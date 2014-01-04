require 'httparty'

module ActiveScraper
  class Fetcher

    attr_accessor :http_method
    def initialize(opts={})
      opts = opts.stringify_keys

      @http_method = opts.fetch('http_method'){ 'get' }.to_sym
    end

    def get?; @http_method == :get; end
    def post?; @http_method == :post; end

    def fetch(u, opts={})
      url = convert_uri_object(u)
      force_fresh = opts.delete :fresh

      if force_fresh != true && (record = fetch_from_cache(url, opts))
        resp_obj = record
      else
        resp_obj = fetch_fresh(url, opts)
      end

      build_response_object(resp_obj)
    end


    def fetch_fresh(url, opts={})
      opts = opts.stringify_keys

      url = url.to_s
      # um, no...
      #verb = opts.fetch('verb'){ 'get' }

      resp = HTTParty.send(@http_method, url)
    end


    # returns: 
    #   single ScrapeCache if a valid ActiveScraper::Request exists
    #   
    def fetch_from_cache(uri, opts={})

    end

    # true or false if ActiveScraper::Request with these parameters exist
    def has_cache?(uri, opts={})

    end


    # u can either be a Request object, a String, or Addressable::URI
    # returns an Addressable::URI
    def convert_uri_object(u)
      if u.is_a?(ActiveScraper::Request)
        x = u.uri
      else
        x = Addressable::URI.parse(u)
      end

      return x
    end

    def build_response_object(obj)
      self.class.build_response_object(obj)
    end

    # returns an OpenStruct that Response can use
    def self.build_response_object(obj)
      return AgnosticResponseObject.new(obj)
    end

  end
end