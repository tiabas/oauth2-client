module OAuth2
  module Grant
    class Base
      include OAuth2::UrlHelper

      class InvalidAuthorizationTypeError < StandardError; end
    
      DEFAULTS_PATHS = {
        :authorize_path     => '/oauth/authorize',
        :token_path         => '/oauth/token',
        :device_path        => '/device/code',
      }

      # attr_reader   :state
      attr_accessor :client_id, :client_secret, :connection

      def initialize(client, options={})
        @connection    = client.connection
        @client_id     = client.client_id
        @client_secret = client.client_secret
        DEFAULTS_PATHS.keys.each do
          instance_variable_set(:"@#{key}", options.fetch(key, DEFAULTS_PATHS[key]))
        end
      end

      def make_request(path, opts={})
        if auth_type = opts.delete(:authenticate)
          case auth_type.to_sym
          when :body
            opts[:params] || = {}
            opts[:params].merge!({
              :client_id     => @client_id,
              :client_secret => @client_secret
            })
          else :headers
            opts[:headers] || {}
            headers['Authorization'] = http_basic_encode(@client_id, @client_secret)
          end
        end
        response = @connection.send_request(method, path, opts)
        yield response if block_given
        response
      end
  end
end
