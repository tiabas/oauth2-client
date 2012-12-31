module OAuth2
  class Client
    
    attr_reader   :host, :connection_options
    attr_accessor :client_id, :client_secret, :connection_client

    def initialize(host, client_id, client_secret, options={})
      @host               = host
      @client_id          = client_id
      @client_secret      = client_secret
      @connection_options = options.fetch(:connection_options, {})
      @connection_client  = options.fetch(:connection_client, OAuth2::HTTPConnection)
    end

    def host=(hostname)
      @connection = nil
      @host = hostname
    end

    def connection_options=(options)
      @connection = nil
      @connection_options = options
    end

    def request

    end

    def implicit(opts={})
      OAuth2::Grant::Implicit.new(self, opts={})
    end

    def authorization_code(opts={})
      OAuth2::Grant::AuthorizationCode.new(self, opts={})
    end

    def refresh_token(opts={})
      OAuth2::Grant::RefreshToken.new(self, opts={})
    end

    def client_credentials(opts={})
      OAuth2::Grant::ClientCredentials.new(self, opts={})
    end

    def password(opts={})
      OAuth2::Grant::Password.new(self, opts={})
    end

    def device_code(opts={})
      OAuth2::Grant::Device.new(self, opts={})
    end

  private

    def connection
      @connection ||= @connection_client.new(@host, @connection_options)
    end
  end
end