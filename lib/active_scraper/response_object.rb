require 'active_scraper/response_object/basic'

module ActiveScraper
  module ResponseObject


    def self.factory(obj)
      ActiveScraper::ResponseObject::Basic.new(obj)
    end


  end
end