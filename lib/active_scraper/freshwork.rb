module ActiveScraper
  module Freshwork
    def get(uri, opts={})
      f = Fetcher.new(opts.stringify_keys.merge('http_method' => 'get'))
      obj = ActiveScraper.create_request_and_fetch_response(uri, opts, f)
      resp = ActiveScraper::Response.new(obj.request, obj.response)

      return resp
    end


    def post(uri, opts={})
      f = Fetcher.new(opts.stringify_keys.merge('http_method' => 'post'))
      
      obj = ActiveScraper.create_request_and_fetch_response(uri, opts, f)
      resp = ActiveScraper::Response.new(obj.request, obj.response)
      
      return resp

    end

  end
end
