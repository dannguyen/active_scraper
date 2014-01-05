require 'active_scraper/response_object/basic'

module ActiveScraper
  module ResponseObject


    def self.factory_cache(obj, meta={})
      Fetched.from_cache(obj, meta)
    end

    def self.factory_fresh(obj, meta={})
      Fetched.from_fresh(obj, meta)
    end



  end
end