module OAuth2
  module Client
    module Grant
      class Password < Base

        def initialize(http_client, opts)
          @grant_type = 'password'
          super(http_client, opts)
        end

        def get_token(username, password, params={}, opts={})
          params.merge!({
            :grant_type => @grant_type,
            :client_id  => @client_id,
            :username   => username,
            :password   => password
          })
          headers = opts[:headers] || {}
          path    = opts[:path]    || @token_path
          method  = opts[:method]  || 'post'
          @http_client.send_request(path, params, method, headers)
        end
      end
    end
  end
end
