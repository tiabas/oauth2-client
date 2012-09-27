module OAuth2
  module Client
    module Grant
      class RefreshToken < Base

        def initialize(http_client, opts)
          @grant_type = 'refresh_token'
          super(http_client, opts)
        end

        # Retrieve an access token for a given refresh token
        #
        # @param [String] refresh_token     refresh token
        # @param [Hash]   params additional params
        # @param [Hash]   opts options
        def get_token(refresh_token, params={}, opts={})
          params.merge!({
            :grant_type    => @grant_type,
            :client_id     => @client_id,
            :refresh_token => refresh_token 
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