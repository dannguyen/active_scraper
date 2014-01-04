module ActiveScraper
  class Response < ActiveRecord::Base
    serialize :headers, Hash
    belongs_to :request
    before_save :set_checksum




    private
    def set_checksum
      self.checksum = body.hash

      true
    end

############## class methods
    def self.build_from_response_object(resp)
      response = self.new
      [:body, :headers, :content_type, :code].each do |att|
        response.send :write_attribute, att, resp.send(att)
      end

      return response
    end
  end
end
