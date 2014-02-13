require 'nokogiri'
module ActiveScraper
  class CachedResponse < ActiveRecord::Base
    serialize :headers, Hash
    belongs_to :request, touch: true, class_name: 'CachedRequest', foreign_key: 'cached_request_id'
    before_create :encode_body_for_create
    before_save :set_checksum

    after_create :touch_request_fetched_at

    def to_fake_party_hash
      [:body, :headers, :content_type, :code].inject(Hashie::Mash.new) do |hsh, att|
        hsh[att] = self.send(att)

        hsh
      end
    end


    def binary?
      content_type =~ /pdf|image/ || !text?
    end

    def json?
      content_type =~ /json/
    end

    def html?
      content_type =~ /html/
    end

    def xml?
      html? || content_type =~ /xml/
    end

    def text?
      content_type =~ /text/ || xml? || json?
    end

    def body_changed?
      self.changed_attributes.keys.include?('body')
    end

    def body
      b = read_attribute(:body)
      if b.present? && binary? && !body_changed?
        return Base64.decode64(b)
      else
        return b
      end
    end
 
    def parsed_body
      @_parsedbody ||= if xml?
        Nokogiri::HTML(body)
      elsif json?
        JSON.parse(body)
      else
        body
      end
    end

    def to_s
      body
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


    # expects @body to be populated
    # returns string: e.g. 'utf-8', 'windows-1251'
    def detect_encoding
      if xml?
        parsed_body.encoding
      else
        body.encoding
      end
    end

    # converts @body to utf-8 if not already
    def encode_body_for_create
      if self.body.present?        
        if binary?
          self.body = Base64.encode64(self.body)
        elsif
          denc = detect_encoding
          self.body = self.body.encode('utf-8', denc)
        end
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

    # has one side-effect: :body is properly encoded
    def self.build_from_response_object(resp)
      response = self.new
      [:body, :headers, :content_type, :code].each do |att|
        response.send :write_attribute, att, resp.send(att)
      end

      return response
    end
  end
end
