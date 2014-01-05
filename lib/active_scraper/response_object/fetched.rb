module ActiveScraper
  module ResponseObject 
    class Fetched < Basic


      def initialize(obj, meta={})
        super(obj)

        meta_opts = meta.stringify_keys
        @is_fresh = meta_opts['is_fresh']
      end

      def fresh?
        @is_fresh
      end



      def self.from_fresh(obj, meta={})
        new(obj, meta.merge(is_fresh: true))
      end

      def self.from_cache(obj, meta={})
        new(obj, meta.merge(is_fresh: false))
      end


    end
  end
end