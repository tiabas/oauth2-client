module OAuth2Client
  module Grant
    class Base < Hash
      include OAuth2Client::Helper

      attr_accessor :client_id, :client_secret, :token_path, 
                    :authorize_path, :http_client

      def initialize(http_client, opts)
        @http_client    = http_client
        @client_id      = opts[:client_id]
        @client_secret  = opts[:client_secret]
        @token_path     = opts[:token_path]
        @authorize_path = opts[:authorize_path]
      end

    end
  end
end
