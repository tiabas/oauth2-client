module OAuth2Client
  module Grant
    # Authorization Code Grant
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.1
    class AuthorizationCode < Base

      attr_reader :response_type, :grant_type

      def initialize(http_client, opts)
        @response_type = 'code'
        @grant_type    = 'authorization_code'
        super(http_client, opts)
      end

      # Authorization Request
      # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.1.1
      def authorization_path
        query_string = to_query(params.merge(authorization_params))
        "#{@authorize_path}?#{to_query}"
      end

      # Retrieve page at authorization path
      #
      # @param [Hash]   params additional params
      # @param [Hash]   opts options
      def get_authorization_url(params={}, opts={})
        params.merge!(authorization_params)
        headers = opts[:headers] || {}
        path    = opts[:path]    || @authorize_path
        method  = opts[:method]  || 'get'
        @http_client.send_request(path, params, method, headers)
      end

      # Access Token Request
      # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.1.3
      def token_path(params)
        query_string = to_query(params.merge(token_params))
        "#{@token_path}?#{query_string}"
      end

      # Retrieve an access token for a given auth code
      #
      # @param [String] code refresh token
      # @param [Hash]   params additional params
      # @param [Hash]   opts options
      def get_token(code, params={}, opts={})
        params.merge!(token_params)
        params[:code] = code
        headers = opts[:headers] || {}
        path    = opts[:path]    || @token_path
        method  = opts[:method]  || 'post'
        @http_client.send_request(path, params, method, headers)
      end

    private

      # Default authorization request parameters
      def authorization_params
        {
          :response_type => @response_type,
          :client_id  => @client_id 
        }
      end

      # Default token request parameters
      def token_params
        {
          :grant_type => @grant_type,
          :client_id  => @client_id 
        }
      end
    end
  end
end
