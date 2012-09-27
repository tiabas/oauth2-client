module OAuth2
  module Client
    module Grant
      # Implicit Grant
      # @see http://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.2
      class Implicit < Base

        def initialize(http_client, opts)
          @response_type = 'token'
          super(http_client, opts)
        end

        # Generate a token path using the given parameters .
        #
        # @param [Hash] query parameters
        def token_path(params)
          query_string = to_query(params.merge(token_params))
          "#{@token_path}?#{query_string}"
        end

        # Retrieve an access token given the specified client.
        #
        # @param [Hash] params additional params
        # @param [Hash] opts options
        def get_token(params={}, opts={})
          params.merge!({
            :response_type => @response_type,
            :client_id     => @client_id
          })
          headers = opts[:headers] || {}
          path    = opts[:path]    || @authorize_path
          method  = opts[:method]  || 'get'
          @http_client.send_request(path, params, method, headers)
        end

      private

        def token_params
          {
            :response_type => @response_type,
            :client_id  => @client_id
          }
        end
      end
    end
  end
end
