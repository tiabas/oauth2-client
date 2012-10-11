module OAuth2Client
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
      def get_token(refresh_token, request_params={}, opts={})

        headers = opts[:headers] || {}
        path    = opts[:path]    || @token_path
        method  = opts[:method]  || 'post'
        params  = params.merge!({
                    :grant_type    => @grant_type,
                    :refresh_token => refresh_token 
                  })

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
