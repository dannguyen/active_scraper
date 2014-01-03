module ActiveScraper
  class AgnosticResponseObject < SimpleDelegator

    attr_reader :code, :headers, :body, :content_type

    def initialize(obj)
      if obj.class == (HTTParty::Response)
        # use the Net::HTTPResponse instead
        obj = obj.response
      end

      response_obj = if obj.is_a?(Net::HTTPResponse)
        @body = obj.body
        @content_type = obj.content_type
        @headers = obj.each_header.inject({}){|h, (k, v)| h[k] = v; h }
        @code = obj.code.to_i
      elsif obj.is_a?(ActiveScraper::Request)
        @body = obj.body
        @content_type = obj.content_type
        @headers = obj.headers
        @code = obj.code.to_i
      else
        # this is probably not used
        @body = obj.to_s
        @headers = {}
        @content_type = nil
        @code = nil
      end

      super({})

      # now set its values
      [:body, :headers, :content_type, :code].each do |a|
        self[a] = self.send(a)
      end
    end

    # def [](k)
    #   @values[k.to_sym]
    # end

    # def [](k,v)
    #   send(:"#{k}=", v)
    # end

  end
end