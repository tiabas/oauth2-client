require 'net/http'

module OAuth2
  module Client
    class Client

      @@authorize_path = "/oauth/authorize"
      @@token_path     = "/oauth/token"

      attr_accessor :config, :client_id, :client_secret, :host, :authorize_path,
                    :token_path, :scheme, :raise_errors, :http_client

      def initialize(config)
        @config       ||= Config.new(:filename => 'oauth_client.yml')
        @client_id      = config.client_id
        @client_secret  = config.client_secret
        @scheme         = config.scheme
        @host           = config.host
        @port           = config.port
        @authorize_path = config.authorize_path || @@authorize_path
        @token_path     = config.token_path]    || @@token_path
        @raise_errors   = config.raise_errors]  || true
        @http_client    = config.http_client    || OAuth2::Client::Connection
      end

      def http_connection
        unless @connection
          @connection = @http_connection.new(config)
        end
        @connection
      end

      def make_request(path, params, method, headers)
        http_connection.send_request(path, params, method, headers)
      end

      def implicit(response_type, opts={})
        Grant::Implicit.new(self, response_type, opts)
      end

      def authorization_code(code, opts={})
        Grant::AuthorizationCode.new(self, code, opts)
      end

      def refresh_token(refresh_token, opts={})
        Grant::RefreshToken.new(self, refresh_token, opts)
      end

      def client_credentials(opts={})
        Grant::ClientCredentials.new(self, opts)
      end

      def password(username, password, opts={})
        Grant::Password.new(self, username, password, opts)
      end
    end
  end
end