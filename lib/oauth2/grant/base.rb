module OAuth2
  module Grant
    class Base
      include OAuth2::UrlHelper

      class InvalidAuthorizationTypeError < StandardError; end
  
      attr_accessor :client_id, :client_secret, :connection,
                    :authorize_path, :token_path, :device_path

      def initialize(client)
        @connection     = client.connection
        @client_id      = client.client_id
        @client_secret  = client.client_secret
        @token_path     = client.token_path
        @authorize_path = client.authorize_path
        @device_path    = client.device_path
      end

      def make_request(method, path, opts={})
        if auth_type = opts.delete(:authenticate)
          case auth_type.to_sym
          when :body
            opts[:params] ||= {}
            opts[:params].merge!({
              :client_id     => @client_id,
              :client_secret => @client_secret
            })
          when :headers
            opts[:headers] ||= {}
            opts[:headers]['Authorization'] = http_basic_encode(@client_id, @client_secret)
          else
            #do nothing
          end
        end
        @connection.send_request(method, path, opts)
      end
    end
  end
end
