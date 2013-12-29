module ActiveScraper
  class Fetcher

    def fetch(uri, opts={})
      if record = fetch_from_cache
        return record
      else
        return fetch_fresh(uri, opts)
      end
    end


    def fetch_fresh(uri, opts={})

    end


    # returns: 
    #   single ScrapeCache if a valid ActiveScraper::Request exists
    #   
    def fetch_from_cache(uri, opts={})

    end

    # true or false if ActiveScraper::Request with these parameters exist
    def has_cache?(uri, opts={})

    end

  end
end