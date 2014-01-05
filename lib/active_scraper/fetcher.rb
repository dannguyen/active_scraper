require 'httparty'

module ActiveScraper
  class Fetcher

    attr_accessor :http_method
    def initialize(opts={})
      opts = opts.stringify_keys

      @http_method = opts.fetch('http_method'){ 'get' }.to_sym
      @last_fetched_before = opts.fetch('last_fetched_before'){ Time.at(0) }
    end

    def get?; @http_method == :get; end
    def post?; @http_method == :post; end

    def last_fetched_before
      @last_fetched_before = Time.parse(@last_fetched_before) if @last_fetched_before.is_a?(String)

      @last_fetched_before
    end

    def fetch(request, opts={})
      options = opts.stringify_keys
            
      if options.delete 'cache_only' == true # only check the cache 
        resp_obj = build_factory_cache    perform_cache_request(request, options)
      elsif options.delete 'fresh' == true # only go for a fresh request
        resp_obj = build_factory_fresh    perform_fresh_request(request, options)
      else
        # check cache, then check fresh
        resp_obj = if (x = perform_cache_request(request, options))
          build_factory_cache(x)
        else
          build_factory_fresh    perform_fresh_request(request, options)
        end
      end

      return resp_obj
    end

    # simple convenience wrapper
    def fetch_fresh(u, opts={})
      options = opts.stringify_keys
      options['fresh'] = true

      fetch(u, options)
    end

    def fetch_cache(u, opts={})
      options = opts.stringify_keys
      options['force_cache'] = true

      fetch(u, options)
    end

    private

    def perform_fresh_request(req, opts={})
      url = req.to_s

      resp = HTTParty.send(@http_method, url, opts)
    end


    def perform_cache_request(req, opts={})
      ActiveScraper.find_cache_for_request(req)
    end

    def build_factory_cache(obj)
      ActiveScraper::ResponseObject.factory_cache(obj)
    end

    def build_factory_fresh(obj)
      ActiveScraper::ResponseObject.factory_fresh(obj)
    end



  end
end