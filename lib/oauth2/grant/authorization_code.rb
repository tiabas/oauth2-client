module OAuth2Client
  module Grant
    # Authorization Code Grant
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.1
    class AuthorizationCode < Base

      def response_type
        "code"
      end

      def grant_type
        "authorization_code"
      end

      # Authorization Request
      # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.1.1
      def authorization_path(params={})
        params = params.merge(authorization_params)
        "#{@authorize_path}?#{to_query(params)}"
      end

      # Retrieve page at authorization path
      #
      # @param [Hash] opts options
      def fetch_authorization_url(opts={})
        opts[:method] ||= :get
        opts[:params] ||= {}
        opts[:params].merge!(authorization_params)
        method = opts[:method] || :get
        make_request(method, @authorize_path, opts)
      end

      # Access Token Request
      # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.1.3
      def token_url(params)
        "#{@token_path}?#{to_query(params)}"
      end

      # Retrieve an access token for a given auth code
      #
      # @param [String] code refresh token
      # @param [Hash]   params additional params
      # @param [Hash]   opts options
      def get_token(code, opts={})
        opts[:params] ||= {}
        opts[:params][:code] = code
        method = opts[:method] || :post
        make_request(method, @token_path, opts)
      end

    private

      # Default authorization request parameters
      def authorization_params
        {
          :response_type => response_type,
          :client_id  => @client_id
        }
      end
    end
  end
end
