require 'httparty'
require 'addressable/uri'
require 'hashie/mash'

module ActiveScraper
  class CachedRequest < ActiveRecord::Base
    has_many :responses, :dependent => :destroy, class_name: 'CachedResponse', foreign_key: 'cached_request_id' 
    has_one :latest_response, ->{ order('created_at DESC') },  class_name: 'ActiveScraper::CachedResponse', foreign_key: 'cached_request_id'
    validates_uniqueness_of :path, scope: [:host, :query, :scheme]

    attr_accessor :unobfuscated_query

    delegate :to_s, :to => :uri

    # problematic
    scope :with_url, ->(u){     
      matching_request(u)
    }

    scope :matching_request, ->(req, opts={}){
      if req.is_a?(CachedRequest)
        req = req.to_uri
      end
      params = CachedRequest.build_validating_params(req, opts)

      where(params)
    }

    scope :last_fetched_before, ->(some_time){
      some_time = Time.parse(some_time) if some_time.is_a?(String)

      where("last_fetched_at < ?", some_time)
    }

    def latest_response_fetched_after(time)
      if latest_response.present?
        return latest_response if latest_response.created_at > time
      end
      
      nil      
    end

    def to_fake_party_hash
      h = Hashie::Mash.new(self.attributes.symbolize_keys.slice(:scheme, :host, :path, :query))
      h[:uri] = self.standard_uri
      h[:options] ||= {}
      h[:headers] ||= {}

      return h
    end



    def obfuscated?
      is_obfuscated == true
    end

    # to follow HTTParty conventions
    def standard_uri
      URI.parse(uri)
    end

    def uri
      to_uri
    end

    # during a fresh query, we need to actually use the unobfuscated_query
    def to_uri
      h = self.attributes.symbolize_keys.slice(:scheme, :host, :path)
      h[:query] = self.unobfuscated_query || self.query

      return Addressable::URI.new(h)
    end

    def self.build_validating_params(uri, opts={})
      h = build_request_params(uri, opts)

      h.slice(:scheme, :host, :path, :query)
    end

#########################################################
############ class methods
    


    # Returns a Hash with symbolized keys
    def self.build_request_params(uri, opts={})
      u = Addressable::URI.parse(uri)
      hsh = {scheme: u.normalized_scheme, host: u.normalized_host, path: u.normalized_path, query: u.normalized_query , extname: u.extname}
      # deal with query separately
      unless opts[:normalize_query] == false
        hsh[:query] = normalize_query_params(hsh[:query])        
      end

      hsh[:unobfuscated_query] = hsh[:query]
      if ob_keys = opts[:obfuscate_query]
        hsh[:query] = obfuscate_query_params(hsh[:query], ob_keys)
        hsh[:is_obfuscated] = true
      else
        hsh[:is_obfuscated] = false
      end

      return hsh
    end

    def self.build_from_uri(uri, opts={})
      request_params = build_request_params(uri, opts)
      request_obj = CachedRequest.new(request_params)

      return request_obj
    end

    def self.find_or_build_from_uri(uri, opts={})
      self.matching_request(uri, opts).first || self.build_from_uri(uri, opts)
    end

1
    def self.create_from_uri(uri, opts={})
      req = build_from_uri(uri, opts)
      req.save

      return req
    end



    QUERY_NORMALIZER = HTTParty::Request::NON_RAILS_QUERY_STRING_NORMALIZER
    # :q is a query String or Hash
    # e.g.   'z=hello&b=world&a=dog'
    #    or: {z: ['hello', 'world'], a: 'dog'}
    #
    # returns: (String) "a=dog&z=hello&z=world"
    def self.normalize_query_params(q)
      return q if q.blank?

      params_hash = CGI.parse(q)
      params_str = QUERY_NORMALIZER[params_hash]

      return params_str
    end


    private 

    def self.obfuscate_query_params(q, ob_keys)
      string = q.dup
      Array(ob_keys).each do |key|
        a = Array(key)

        key_to_omit = Regexp.escape(a[0].to_s)
        char_num = a[1] || 0        
        if val_to_omit = string.match(/(?<=#{key_to_omit}=)(.*?)(?=&|$)/)
          val = val_to_omit[1]
          string.sub!( val, "__OMIT__#{val[-char_num, char_num]}")
        end
      end

      return string
    end


  end
end
