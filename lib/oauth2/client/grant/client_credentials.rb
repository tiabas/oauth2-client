module OAuth2
  module Client
    module Grant
      # Client Credentials Grant
      #
      # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.4
      class ClientCredentials < Base
        def initialize(http_client, opts)
          @grant_type = 'client_credentials'
          super(http_client, opts)
        end

        def get_token(params={}, opts={})
          params.merge!({
            :grant_type    => @grant_type,
            :client_id     => @client_id,
            :client_secret => @client_secret
          })
          headers = opts[:headers] || {}
          path    = opts[:path]    || @token_path
          method  = opts[:method]  || 'post'
          @http_client.send_request(path, params, method, headers)
        end
      end
    end
  end
end
