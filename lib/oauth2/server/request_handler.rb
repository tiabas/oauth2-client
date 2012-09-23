module OAuth2
  module Server
    class RequestHandler

      attr_reader :request

      def self.from_request_params(params, config_file=nil)
        unless params.is_a? Hash
          raise "Request params must be a hash not #{params.class.name}"
        end
        req = OAuth2::Server::Request.new(params)
        return new(req, config_file)
      end

      def initialize(request, config_file=nil)
        unless request.is_a? OAuth2::Server::Request
          raise "OAuth2::Server::Request expected but got #{request.class.name}"
        end
        @request = request
        @config = Config.new(config_file)
        @user_datastore = @config.user_datastore
        @client_datastore = @config.client_datastore
        @token_datastore = @config.token_datastore
        @code_datastore = @config.code_datastore
      end

      def client_application
        @client || verify_client_id
      end

      def user
        @user || verify_user_credentials
      end

      def redirect_uri
        @redirect_uri || verify_redirect_uri
      end

      def fetch_authorization_code(user)
        @request.validate!

        verify_client_id
        
        unless @request.response_type?(:code)
          raise OAuth2Error::UnsupportedResponseType, "unsupported response_type #{@response_type}"
        end
        @code_datastore.generate_authorization_code client_application, user, redirect_uri
      end

      def authorization_code_response(user)
        # {
        #   :code => "2YotnFZFEjr1zCsicMWpAA",
        #   :state => "auth",
        # }
        response = {
          :code => fetch_authorization_code(user)
        }
        response[:state] = @request.state unless @request.state.nil?
        response
      end

      def fetch_access_token(auth_user=nil, opts={})
        # {
        #   :access_token => "2YotnFZFEjr1zCsicMWpAA", 
        #   :token_type => "bearer",
        #   :expires_in => 3600,
        #   :refresh_token => "tGzv3JOkF0XG5Qx2TlKWIA",
        # }
        return @token unless @token.nil?

        @request.validate!

        auth_client = verify_client_id

        if auth_user.nil? && !['refresh_token', 'client_credentials'].include?(@request.grant_type.to_s)
          raise "A user must be specified for this type of request"
        end

        unless (@request.grant_type || @request.response_type?(:token))
          # grant type validity is checked in the request object. Therefore if this
          # condition fails, the response_type is to blame
          raise OAuth2Error::InvalidRequest, "#response_type: #{@response_type} is not valid for this request"
        end

        if @request.response_type?(:token)
          opts[:refresh_token] = false

        elsif @request.grant_type?(:authorization_code)
          code = verify_authorization_code

        elsif @request.grant_type?(:password)
          auth_user = verify_user_credentials

        elsif @request.grant_type?(:client_credentials)
          verify_client_credentials
        end

        if @request.grant_type?(:refresh_token) 
          @token = @token_datastore.from_refresh_token(@request.refresh_token)
          unless @token
            raise OAuth2::OAuth2Error::InvalidRequest, "invalid refresh token"
          end
          return @token
        end

        # run some user code before generating token
        yield if block_given?

        opts[:scope] = @request.scope
        @token = @token_datastore.generate_token(auth_client, auth_user, opts) 

        # deactivate used authorization code if present
        code.deactivate! unless code.nil?

        @token
      end

      def access_token_response(user=nil, opts={})
        token = fetch_access_token(user, opts)
        token_response = token.to_hash
        token_response[:state] = @request.state if @request.state
        token_response
      end

      def authorization_redirect_uri(user) 
        # https://client.example.com/cb?code=SplxlOBeZQQYbYS6WxSbIA&state=xyz
        build_response_uri redirect_uri, :query => authorization_code_response(user)
      end

      def access_token_redirect_uri(user, opts={})
        # http://example.com/cb#access_token=2YotnFZFEjr1zCsicMWpAA&state=xyz&token_type=example&expires_in=3600
        build_response_uri redirect_uri, :fragment => access_token_response(user, opts)
      end

      def error_redirect_uri(error)
        # http://example.com/cb#error=access_denied&error_description=the+user+denied+your+request
        unless error.respond_to? :to_hsh
          raise "Invalid error type. Expected OAuth2::OAuth2Error but got #{error.class.name} "
        end
        build_response_uri redirect_uri, :query => error.to_hsh
      end


      def verify_client_id
        @request.validate!
        @client = @client_datastore.find_client_with_id(@request.client_id)
        return @client if @client
        raise OAuth2::OAuth2Error::InvalidClient, "unknown client"
      end

      def verify_user_credentials
        @request.validate!
        @user = @user_datastore.authenticate request.username, request.password
        return @user if @user
        raise OAuth2::OAuth2Error::AccessDenied, "user authentication failed"
      end

      def verify_client_credentials
        @request.validate!
        @client = @client_datastore.authenticate @request.client_id, @request.client_secret
        return @client if @client
        raise OAuth2::OAuth2Error::InvalidClient, "client authentication failed"
      end

      def verify_authorization_code
        @request.validate!
        # TODO:
        # consider doing the find thru the client application
        # client_application.authorization_codes.where @request.code, @request.redirect_uri
        auth_code = @code_datastore.verify_authorization_code client_application, @request.code, redirect_uri
        if auth_code.nil? || auth_code.expired? || auth_code.deactivated?
          raise OAuth2::OAuth2Error::InvalidGrant, "invalid authorization code"
        end
        auth_code
      end

      def verify_request_scope
        @request.validate!
        # return true if @token_datastore.validate_scope(@request.scope)
        # raise OAuth2::OAuth2Error::InvalidRequest, "invalid scope" 
      end

      def verify_redirect_uri
        @request.validate!
        # TODO: parse the URI hostname and path from request redirect
        @redirect_uri = @request.redirect_uri
        if @redirect_uri && (@redirect_uri != client_application.redirect_uri)
          raise OAuth2::OAuth2Error::InvalidRequest, "invalid redirect uri"
        end
        @redirect_uri ||= client_application.redirect_uri
        @redirect_uri 
      end

    private

      # convenience method to build response URI  
      def build_response_uri(redirect_uri, opts={})
        query= opts[:query]
        fragment= opts[:fragment]
        unless ((query && query.is_a?(Hash)) || (fragment && fragment.is_a?(Hash)))
          # TODO: make sure error message is more descriptive i.e query if query, fragment if fragment
          raise "Hash expected but got: query: #{query.inspect}, fragment: #{fragment.inspect}"
        end
        uri = Addressable::URI.parse redirect_uri
        temp_query = uri.query_values || {}
        temp_frag = uri.fragment || nil
        uri.query_values = temp_query.merge(query) unless query.nil?
        uri.fragment = Addressable::URI.form_encode(fragment) unless fragment.nil?
        uri.to_s
      end
    end
  end
end
