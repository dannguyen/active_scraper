module ActiveScraper
  module Cachework
    # :r can be a Request, a URI, or a String

    def find_cache_for_request(r, opts={})
      if request = ActiveScraper::CachedRequest.matching_request(r).first
        return request.latest_response
      end
    end


    def request_cached?(req)
      find_cache_for_request(req).present?
    end

  end
end
