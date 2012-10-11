require 'net/http'

module OAuth2Client
  class Client

    @@authorize_path = "/oauth/authorize"
    @@token_path     = "/oauth/token"

    attr_accessor :config, :client_id, :client_secret, :host, :authorize_path,
                  :token_path, :scheme, :raise_errors, :http_client

    def initialize(config)
      raise "You must provide a configuration" unless config
      @config         = config
      @config         = OAuth2Client::Config.new(:filename => config) if config.is_a?(String)
      @client_id      = config.client_id
      @client_secret  = config.client_secret
      @scheme         = config.scheme
      @host           = config.host
      @port           = config.port
      @authorize_path = config.authorize_path || @@authorize_path
      @token_path     = config.token_path     || @@token_path
      @http_client    = OAuth2Client::Connection
    end

    def http_connection
      unless @connection
        @connection = @http_client.new(@config)
      end
      @connection
    end

    def site
      "#{scheme}://#{host}"
    end

    def grant_params
      {
        :client_id => @client_id,
        :client_secret => @client_secret,
        :token_path => @token_path,
        :authorize_path => authorize_path
      }
    end

    def implicit
      Grant::Implicit.new(http_connection, grant_params)
    end

    def authorization_code
      @auth_code ||= Grant::AuthorizationCode.new(http_connection, grant_params)
    end

    def refresh_token
      @refresh_token ||= Grant::RefreshToken.new(http_connection, grant_params)
    end

    def client_credentials
      @client_credentials ||= Grant::ClientCredentials.new(http_connection, grant_params)
    end

    def password
      @password ||= Grant::Password.new(http_connection, grant_params)
    end
  end
end