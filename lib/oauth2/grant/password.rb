module OAuth2
  module Grant
    class Password < Base

      def grant_type
        'password'
      end

      # Retrieve an access token given the specified client.
      #
      # @param username
      # @param password
      # @param [Hash] params additional params
      # @param [Hash] opts options
      def get_token(username, password, opts={})
        opts[:params] ||= {}
        opts[:params].merge!({
          :grant_type => grant_type,
          :username   => username,
          :password   => password
        })
        method = opts.delete(:method) || :post
        make_request(method, @token_path, opts)
      end
    end
  end
end
