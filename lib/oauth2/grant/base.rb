module OAuth2Client
  module Grant
    class Base
      include OAuth2Client::UrlHelper

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
        if auth = opts.delete(:authenticate)
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
        @connection.send_request(method, path, opts)
      end
  end
end
