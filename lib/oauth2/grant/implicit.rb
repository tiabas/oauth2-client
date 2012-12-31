module OAuth2Client
  module Grant
    # Implicit Grant
    # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.2
    class Implicit < Base

      def response_type
        "token"
      end

      # Generate a token path using the given parameters .
      #
      # @param [Hash] query parameters
      def token_url(params={})
        params = params.merge(token_params)
        "#{@authorize_path}?#{to_query(params)}"
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(opts={})
        opts[:params] ||= {}
        opts[:params].merge!(token_params)
        method = opts[:method] || :get
        make_request(method, @authorize_path, opts)
      end

    private

      def token_params
        {
          :response_type => response_type,
          :client_id  => @client_id
        }
      end
    end
  end
end
