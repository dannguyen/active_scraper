require 'httparty'

module ActiveScraper
  class Response < HTTParty::Response


    def initialize(request, response, parsed_block=nil, options={})
      request = request.to_fake_party_hash if request.is_a?(CachedRequest)
      response = response.to_fake_party_hash if response.is_a?(CachedResponse)

      ## making HTTParty happy...

      parsed_block ||= ->(){ response.body }

      super(request, response, parsed_block, options)
    end

  end
end