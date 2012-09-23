module OAuth2
  module Client
    module Grant
      class Base < Hash

        attr_accessor :client_id, :client_secret

        # class << self
        #   protected :new
        # end

        def initialize(client, opts={})
          @client = client
          self[:client_id] = client.client_id
          self[:client_secret] = client.client_secret
          opts.each do |param, value|
            next if self[param] || value.nil?
            self[param.to_sym] = value
          end
        end

        def grant_type
          self[:grant_type]
        end

        def response_type
          self[:response_type]
        end

        def request(opts={})
          path    = opts[:path]
          headers = opts[:headers] || {}
          params  = opts[:params]  || {}
          method  = opts[:method]  || 'post'
          params.merge!(self)
          @client.make_request(path, params, method, headers)
        end

        def get_token(opts={})
          opts[:path] ||= @client.token_path
          response = request(opts)
          yield response if block_given?
        end

        def to_query
          Addressable::URI.form_encode(self)
        end

        def to_url(path)
          uri = Addressable::URI.new(
                :scheme => @client.scheme,
                :host   => @client.host,
                :path   => path
                )
          uri.query_values = self
          uri.to_s
        end
      end
    end
  end
end
