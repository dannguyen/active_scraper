require 'httparty'
require 'addressable/uri'

module ActiveScraper
  class Request < ActiveRecord::Base
    has_many :responses, :dependent => :destroy 
    has_one :latest_response, ->{ order('created_at DESC') },  class_name: 'ActiveScraper::Response'
    validates_uniqueness_of :path, scope: [:host, :query, :scheme]


    scope :with_url, ->(u){     
      params = Request.build_validating_params(u)
      where(params)
    }

    scope :last_fetched_before, ->(some_time){
      some_time = Time.parse(some_time) if some_time.is_a?(String)

      where("last_fetched_at < ?", some_time)
    }


    def obfuscated?
      is_obfuscated == true
    end

    def uri
      Addressable::URI.new(
        self.attributes.symbolize_keys.slice(:scheme, :host, :path, :query)
      )
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
      unless opts.delete(:normalize_query) == false
        hsh[:query] = normalize_query_params(hsh[:query])        
      end

      if ob_keys = opts.delete(:obfuscate_query)
        hsh[:query] = obfuscate_query_params(hsh[:query], ob_keys)
        hsh[:is_obfuscated] = true
      else
        hsh[:is_obfuscated] = false
      end

      return hsh
    end

    def self.build_from_uri(uri, opts={})
      request_params = build_request_params(uri, opts)
      request_obj = Request.new(request_params)

      return request_obj
    end

    def self.find_or_build_from_uri(uri, opts={})
      self.with_url(uri).first || self.build_from_uri(uri, opts)
    end


    def self.create_from_uri(uri, opts={})
      req = build_from_uri(uri, opts)
      req.save

      return req
    end


    def self.create_and_fetch_response(uri, opts={}, fetcher = nil)
      request = find_or_build_from_uri(uri, opts)
      fetcher = fetcher || Fetcher.new

      if request.id.nil? 
        # this request is new
        # so skip to the fresh
        resp = fetcher.fetch request, fresh: true 
      else 
        # will check the cache and the fresh
        resp = fetcher.fetch request
      end

      # build the response
      response = request.responses.build(resp)
      # theoretically, response will be saved too
      request.save

      return request
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
