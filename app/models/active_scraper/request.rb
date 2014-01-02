require 'addressable/uri'
module ActiveScraper
  class Request < ActiveRecord::Base
    has_many :responses, :dependent => :destroy
    validates_uniqueness_of :path, scope: [:host, :query, :scheme]


    scope :with_url, ->(u){     
      params = Request.build_validating_params(u)
      where(params)
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

    # Returns a Hash with symbolized keys
    def self.build_request_params(uri, opts={})
      u = Addressable::URI.parse(uri)
      hsh = {scheme: u.normalized_scheme, host: u.normalized_host, path: u.normalized_path, query: u.normalized_query, extname: u.extname}

      if ob_keys = opts.delete(:obfuscate_query)
        Array(ob_keys).each do |key|
          a = Array(key)

          key_to_omit = Regexp.escape(a[0].to_s)
          char_num = a[1] || 0
          
          if val_to_omit = hsh[:query].match(/(?<=#{key_to_omit}=)(.*?)(?=&|$)/)
            val = val_to_omit[1]
            hsh[:query].sub!( val, "__OMIT__#{val[-char_num, char_num]}")
          end
        end

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
      req = find_or_build_from_uri(uri, opts)
      fetcher = fetcher || Fetcher.new

      if req.id.nil? # this request is new
        # so skip to the fresh
        fetcher.fetch_fresh(req)
      else 
        # will check the cache and the fresh
        fetcher.fetch req
      end
    end

  end
end
