module ActiveScraper
  class CachedResponse < ActiveRecord::Base
    serialize :headers, Hash
    belongs_to :request, touch: true, class_name: 'CachedRequest', foreign_key: 'cached_request_id'
    before_save :set_checksum
    after_create :touch_request_fetched_at

    def to_fake_party_hash
      [:body, :headers, :content_type, :code].inject(Hashie::Mash.new) do |hsh, att|
        hsh[att] = self.send(att)

        hsh
      end
    end



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
    def self.find_cache_for_cached_request(cached_request, opts={})
       time = opts[:fetched_after] || Time.at(0)
       # smell: just goes back to CachedRequest
       cached_request.latest_response_fetched_after(time)       
    end

    def self.find_cache_for_request(req, opts)
      # TODO
    end

    def self.build_from_response_object(resp)
      response = self.new
      [:body, :headers, :content_type, :code].each do |att|
        response.send :write_attribute, att, resp.send(att)
      end

      return response
    end
  end
end
