module OAuth2Client
  module Grant
    # Device Grant
    # @see https://developers.google.com/accounts/docs/OAuth2ForDevices
    class Device < Base

      def grant_type
        "http://oauth.net/grant_type/device/1.0"
      end

      # Generate the authorization path using the given parameters .
      #
      # @param [Hash] query parameters
      def get_code(params={})
        opts[:method] ||= :post
        opts[:params] ||= {}
        opts[:params][:client_id] = @client_id
        make_request(@token_path, opts)
      end

      # Retrieve an access token given the specified client.
      #
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(code, opts={})
        opts[:params] ||= {}
        opts[:params].merge!({
          :code       => code,
          :grant_type => grant_type
        })
        method = opts[:method] || :post
        make_request(method, @token_path, opts)
      end
    end
  end
end
