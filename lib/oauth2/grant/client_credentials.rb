require "base64"

module OAuth2Client
  module Grant
    class InvalidAuthorizationTypeError < StandardError; end
    # Client Credentials Grant
    #
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.4
    class ClientCredentials < Base

      def initialize(http_client, opts)
        @grant_type = 'client_credentials'
        super(http_client, opts)
      end

      # Retrieve an access token for the given client credentials
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(request_params={}, opts={})
        headers = opts[:headers] || {}
        path    = opts[:path]    || @token_path
        method  = opts[:method]  || 'post'
        params  = request_params.merge({:grant_type => @grant_type})

        # set up client credentials based on authentication type
        auth_type = opts.delete(:auth_type) || 'body'
        case auth_type
        when 'body'
          params.merge!({
            :client_id => @client_id,
            :client_secret => @client_secret
          })
        when 'header'
          headers['Authorization'] = http_basic_encode(@client, @client_secret)
        else
          raise InvalidAuthorizationTypeError.new("Unsupported auth_type, #{auth_type}, expected: header or body")
        end

        @http_client.send_request(path, params, method, headers)
      end
    end
  end
end
