require 'addressable/uri'
module ActiveScraper
  class Request < ActiveRecord::Base
    has_many :responses, :dependent => :destroy

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

    def self.create_from_uri(uri)
      u = Addressable::URI.parse(uri)
      # TODO
    end

  end
end
