require 'httparty'

module ActiveScraper
  class Fetcher

    def fetch(u, opts={})
      url = convert_uri_object(u)

      if record = fetch_from_cache(url, opts)
        return record
      else
        return fetch_fresh(url, opts)
      end
    end


    def fetch_fresh(u, opts={})
      url = convert_uri_object(u)
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
    # returns a url String
    def convert_uri_object(u)
      if u.is_a?(ActiveScraper::Request)
        x = u.uri
      else
        x = Addressable::URI.parse(u)
      end

      return x.to_s
    end

    # returns an OpenStruct that Response can use
    def self.build_response_object(obj)
      if obj.class == (HTTParty::Response)
        # use the Net::HTTPResponse instead
        obj = obj.response
      end

      response_obj = if obj.is_a?(Net::HTTPResponse)
        OpenStruct.new( body: obj.body, content_type: obj.content_type, 
          code: obj.code.to_i, 
          headers: obj.each_header.inject({}){|h, (k, v)| h[k] = v; h }
        )
      else
        OpenStruct.new(body: obj.to_s, headers: {}, content_type: nil, code: nil)
      end

      return response_obj
    end

  end
end