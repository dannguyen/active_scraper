require 'addressable/uri'
module ActiveScraper
  class Request < ActiveRecord::Base
    has_many :responses, :dependent => :destroy
    validates_uniqueness_of :path, scope: [:host, :query]

    def obfuscated?
      is_obfuscated == true
    end

    def self.build_request_params(uri, opts={})
      u = Addressable::URI.parse(uri)
      hsh = {host: u.normalized_host, path: u.normalized_path, query: u.normalized_query, extname: u.extname}

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


    def self.create_from_uri(uri, opts={})
      req = build_from_uri(uri, opts)
      req.save

      return req
    end


    def self.create_and_fetch_response(uri, opts={}, fetcher = nil)
      req = build_from_uri(uri, opts)      
      fetcher = Fetcher.new
      # this will break
      fetcher.fetch req
    end

  end
end
