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
      def get_token(params={}, opts={})
        auth_type = opts.delete(:auth_type) || 'body'
        params.merge!({
          :grant_type => @grant_type
        })
        headers = opts[:headers] || {}

        case auth_type
        when 'body'
          params.merge!({
            :client_id => @client_id,
            :client_secret => @client_secret
          })
        when 'header'
          headers['Authorization'] = "Basic #{pack_credentials(@client, @client_secret)}"
        else
          raise InvalidAuthorizationTypeError.new("Unsupported auth_type #{auth_type}, expected: header or body")
        end

        path    = opts[:path]    || @token_path
        method  = opts[:method]  || 'post'
        @http_client.send_request(path, params, method, headers)
      end

    private

      def pack_credentials(username, password)
        ["#{username}:#{password}"].pack("m0")
      end
    end
  end
end
