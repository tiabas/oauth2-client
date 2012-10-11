module OAuth2Client
  module Grant
    class Password < Base

      def initialize(http_client, opts)
        @grant_type = 'password'
        super(http_client, opts)
      end

      # Retrieve an access token given the specified client.
      #
      # @param username
      # @param password
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(username, password, request_params={}, opts={})

        headers = opts[:headers] || {}
        path    = opts[:path]    || @token_path
        method  = opts[:method]  || 'post'
        params  = request_params.merge!({
                    :grant_type => @grant_type,
                    :username   => username,
                    :password   => password
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
