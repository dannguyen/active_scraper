module ActiveScraper
  class Response < ActiveRecord::Base
    serialize :headers, Hash
    belongs_to :request, touch: true
    before_save :set_checksum
    after_create :touch_request_fetched_at




    private
    def set_checksum
      self.checksum = body.hash

      true
    end

    def touch_request_fetched_at
      if request && !request.new_record?
        request.update_attributes(last_fetched_at: self.created_at) if self == request.latest_response
      end

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
