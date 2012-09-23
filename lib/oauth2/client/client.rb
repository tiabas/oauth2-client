require 'net/http'

module OAuth2
  module Client
    class Client

      @@authorize_path = "/oauth/authorize"
      @@token_path     = "/oauth/token"

      attr_accessor :client_id, :client_secret, :host, :authorize_path,
                    :token_path, :scheme, :raise_errors, :http_client

      def initialize(client_id, client_secret, scheme, host, opts={})
        @client_id = client_id
        @client_secret = client_secret
        @scheme = scheme
        @host = host
        @port = opts[:port]
        @authorize_path = opts[:authorize_path] || @@authorize_path
        @token_path = opts[:token_path] || @@token_path
        @raise_errors = opts[:raise_errors] || true
        @http_client = opts[:http_client] || OAuth2::Client::Connection
      end

      def http_connection
        unless @connection
          @connection = @http_connection.new(@scheme, @host, @port)
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