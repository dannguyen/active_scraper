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
      elsif obj.is_a?(ActiveScraper::Response)
        @body = obj.body
        @content_type = obj.content_type
        @headers = obj.headers
        @code = obj.code.to_i
      elsif obj.is_a?(StringIO) && obj.respond_to?(:meta) # OpenURI.open
        @body = obj.read
        @content_type = obj.content_type
        @headers = obj.meta
        @code = obj.status[0].to_i
      else
        # other types have to raise an Error
        raise ArgumentError, 'Improper class type'
      end

      super(ActiveSupport::HashWithIndifferentAccess.new() )

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