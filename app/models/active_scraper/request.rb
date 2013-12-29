require 'addressable/uri'
module ActiveScraper
  class Request < ActiveRecord::Base
    has_many :responses, :dependent => :destroy

    def self.build_request_params(uri, opts={})
      u = Addressable::URI.parse(uri)
      return {host: u.normalized_host, path: u.normalized_path, query: u.normalized_query, extname: u.extname}
    end

    def self.create_from_uri(uri)
      u = Addressable::URI.parse(uri)
      # TODO
    end

  end
end
