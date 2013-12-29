module ActiveScraper
  class Response < ActiveRecord::Base
    belongs_to :request
  end
end
