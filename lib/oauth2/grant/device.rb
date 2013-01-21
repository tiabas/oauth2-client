module OAuth2
  module Grant
    # Device Grant
    # @see https://developers.google.com/accounts/docs/OAuth2ForDevices
    class DeviceCode < Base

      def grant_type
        "http://oauth.net/grant_type/device/1.0"
      end

      # Generate the authorization path using the given parameters .
      #
      # @param [Hash] query parameters
      def get_user_code(opts={})
        opts[:params] ||= {}
        opts[:params][:client_id] = @client_id
        method = opts.delete(:method) || :post
        make_request(method, @token_path, opts)
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
        opts[:authenticate] ||= :headers
        method = opts.delete(:method) || :post
        make_request(method, @token_path, opts)
      end
    end
  end
end
