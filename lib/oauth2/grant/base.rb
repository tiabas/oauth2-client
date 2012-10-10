module OAuth2Client
  module Grant
    class Base < Hash

      attr_accessor :client_id, :client_secret, :token_path, 
                    :authorize_path, :http_client

      def initialize(http_client, opts)
        @http_client    = http_client
        @client_id      = opts[:client_id]
        @client_secret  = opts[:client_secret]
        @token_path     = opts[:token_path]
        @authorize_path = opts[:authorize_path]
      end

    private

      # Convert a hash to a URI query string
      #
      # @params [Hash] params URI parameters
      def to_query(params)
        unless params.is_a?(Hash)
          raise "Expected Hash but got #{params.class.name}"
        end
        Addressable::URI.form_encode(params)
      end
    end
  end
end
