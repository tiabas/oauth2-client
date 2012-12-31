require "base64"

module OAuth2Client
  module Grant
    # Client Credentials Grant
    #
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.4
    class ClientCredentials < Base

      def grant_type 
        "client_credentials"
      end

      # Retrieve an access token for the given client credentials
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(opts={})
        opts[:params] ||= {}
        opts[:params][:grant_type] = grant_type
        method = opts[:method] || :post
        make_request(method, @token_path, opts)
      end
    end
  end
end
