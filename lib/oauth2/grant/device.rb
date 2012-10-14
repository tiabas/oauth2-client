module OAuth2Client
  module Grant
    # Device Grant
    # @see https://developers.google.com/accounts/docs/OAuth2ForDevices
    class Device < Base

      def initialize(http_client, opts)
        @grant_type = "http://oauth.net/grant_type/device/1.0"
        super(http_client, opts)
      end

      def query(params={})
        params = params.merge(authorize_params)
        query_string = to_query(params)
      end

      # Generate the authorization path using the given parameters .
      #
      # @param [Hash] query parameters
      def authorization_path(params={})
        "#{@device_path}?#{query(params)}"
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(code, opts={})
        headers = opts[:headers] || {}
        path    = opts[:path]    || @token_path
        method  = opts[:method]  || 'post'
        params  = opts[:params]  || {}
        params[:code] = code
        params.merge!(token_params)
        @http_client.send_request(path, params, method, headers)
      end

    private

      def authorize_params
        { :client_id => @client_id }
      end

      def token_params
        {
          :grant_type => @grant_type,
          :client_id  => @client_id,
          :client_secret => @client_secret
        }
      end
    end
  end
end
