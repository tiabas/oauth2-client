module OAuth2
  class Client
    
    attr_reader   :host, :connection_options
    attr_accessor :client_id, :client_secret, :connection_client,
                  :authorize_path, :token_path, :device_path

    DEFAULTS_PATHS = {
      :authorize_path     => '/oauth2/authorize',
      :token_path         => '/oauth2/token',
      :device_path        => '/oauth2/device/code',
    }

    def initialize(host, client_id, client_secret, options={})
      @host               = host
      @client_id          = client_id
      @client_secret      = client_secret
      @connection_options = options.fetch(:connection_options, {})
      @connection_client  = options.fetch(:connection_client, OAuth2::HttpConnection)
      DEFAULTS_PATHS.keys.each do |key|
        instance_variable_set(:"@#{key}", options.fetch(key, DEFAULTS_PATHS[key]))
      end
    end

    def host=(hostname)
      @connection = nil
      @host = hostname
    end

    def connection_options=(options)
      @connection = nil
      @connection_options = options
    end

    def implicit
      OAuth2::Grant::Implicit.new(self)
    end

    def authorization_code
      OAuth2::Grant::AuthorizationCode.new(self)
    end

    def refresh_token
      OAuth2::Grant::RefreshToken.new(self)
    end

    def client_credentials
      OAuth2::Grant::ClientCredentials.new(self)
    end

    def password
      OAuth2::Grant::Password.new(self)
    end

    def device_code
      OAuth2::Grant::DeviceCode.new(self)
    end

    def connection
      @connection ||= @connection_client.new(@host, @connection_options)
    end
  end
end