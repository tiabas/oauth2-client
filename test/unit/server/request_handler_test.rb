class RequestHandlerTest < MiniTest::Unit::TestCase

  def setup
    @code = 'G3Y6jU3a'
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @access_token = '2YotnFZFEjr1zCsicMWpAA'
    @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
    @expires_in = 3600
    @state = 'xyz'
    @scope = "scope1 scope2"
    @token_type = 'Bearer'
    @redirect_uri = 'https://client.example.com/oauth_v2/cb'
    @client_app = mock()
    @client_app.stubs(:redirect_uri).returns(@redirect_uri)
    @token = mock()
    @token_response = {
      :access_token => @access_token,
      :refresh_token => @refresh_token,
      :token_type => @token_type,
      :expires_in =>  @expires_in,
    }
    @token.stubs(:to_hash).returns(@token_response)
    @config_file = TEST_ROOT+'/mocks/oauth_config.yml'
    @mock_code = mock()
    @mock_user = mock()
    @mock_client = mock()
    @mock_token = mock()
    @config = mock()
    @config.stubs(:user_datastore).returns(@mock_user)
    @config.stubs(:client_datastore).returns(@mock_client)
    @config.stubs(:code_datastore).returns(@mock_code)
    @config.stubs(:token_datastore).returns(@mock_token)
    @config.client_datastore.stubs(:find_client_with_id).returns(@client_app)
    OAuth2::Server::Config.stubs(:new).returns(@config)
  end
  # Authorization Code Flow

  # Authorization redirect URI
  def test_should_raise_invalid_client_with_response_type_code_and_invalid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state,
                        :scope => @scope
                        })
    @config.client_datastore.stubs(:find_client_with_id).returns(nil)
    request_handler = OAuth2::Server::RequestHandler.new(request)
    
    assert_raises OAuth2::OAuth2Error::InvalidClient do
      request_handler.fetch_authorization_code(@mock_user)
    end
  end

  def test_should_return_authorization_code_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state,
                        :scope => @scope
                        })
    @config.code_datastore.expects(:generate_authorization_code).returns(@code)
    request_handler = OAuth2::Server::RequestHandler.new(request)

    assert_equal @code, request_handler.fetch_authorization_code(@mock_user)
  end

  def test_should_return_code_and_state_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state,
                        :scope => @scope
                        })
    @config.code_datastore.expects(:generate_authorization_code).returns(@code)

    request_handler = OAuth2::Server::RequestHandler.new(request)
    response = { :code=> @code, :state=> @state }

    assert_equal response, request_handler.authorization_code_response(@mock_user)
  end

  def test_should_return_code_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri
                        })
    @config.code_datastore.expects(:generate_authorization_code).returns(@code)

    request_handler = OAuth2::Server::RequestHandler.new(request)
    response = { :code=> @code }

    assert_equal response, request_handler.authorization_code_response(@mock_user)
  end

  def test_should_return_authorization_redirect_with_response_type_code_and_valid_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state,
                        :scope => @scope
                        })
    @config.code_datastore.expects(:generate_authorization_code).returns(@code)

    request_handler = OAuth2::Server::RequestHandler.new(request)
    redirect_uri = "#{@redirect_uri}?code=#{@code}&state=#{@state}"

    assert_equal redirect_uri, request_handler.authorization_redirect_uri(@mock_user)
  end

  def test_should_raise_unsupported_response_type_with_invalid_response_type_code_and_client_id
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => @state,
                        :scope => @scope
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request_handler.access_token_response @mock_user
    end
  end

  def test_should_raise_error_with_grant_type_authorization_code_and_invalid_code
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => '7xI4fk3Z',
                        :state => @state,
                        :scope => @scope
                        })
    @config.code_datastore.expects(:verify_authorization_code).with(@client_app, '7xI4fk3Z', @redirect_uri).returns(nil)
    request_handler = OAuth2::Server::RequestHandler.new(request)

    assert_raises OAuth2::OAuth2Error::InvalidGrant do
      request_handler.access_token_response @mock_user
    end
  end

  def test_should_return_token_hash_with_grant_type_authorization_code_and_valid_code
    redirect_uri = "#{@redirect_uri}#access_token=#{@access_token}&state=#{@state}&token_type=#{@token_type}&expires_in=#{@expires_in}"
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => @code,
                        :state => @state,
                        :scope => @scope
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    @config.code_datastore.expects(:verify_authorization_code).with(@client_app, @code, @redirect_uri).returns(@mock_code)
    @mock_code.expects(:expired?).returns(false)
    @mock_code.expects(:deactivated?).returns(false)
    @config.token_datastore.expects(:generate_token).with(@client_app, @mock_user, {:scope => 'scope1 scope2'}).returns(@token)
    @mock_code.expects(:deactivate!).returns(false)
    assert_equal @token_response, request_handler.access_token_response(@mock_user)
  end

  def test_should_raise_error_with_grant_type_client_credentials_and_invalid_credentials
    @config.client_datastore.stubs(:authenticate).returns(nil)
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :client_secret => @client_secret,
                        :grant_type => 'client_credentials',
                        :state => @state,
                        :scope => @scope
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    assert_raises OAuth2::OAuth2Error::InvalidClient do
      request_handler.access_token_response(@mock_user)
    end
  end

  def test_should_return_token_hash_with_grant_type_client_credentials_and_valid_credentials
    @config.client_datastore.stubs(:authenticate).returns(@client_app)
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :client_secret => @client_secret,
                        :grant_type => 'client_credentials',
                        :state => @state,
                        :scope => @scope
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    @config.token_datastore.expects(:generate_token).with(@client_app, nil, {:scope => 'scope1 scope2'}).returns(@token)
    assert_equal @token_response, request_handler.access_token_response
  end

  def test_should_raise_error_with_grant_type_password_and_invalid_credentials
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :username => 'jacksparrow',
                        :password => 'Q3zXj3w',
                        :grant_type => 'password',
                        :state => @state,
                        :scope => @scope
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    @config.user_datastore.expects(:authenticate).with('jacksparrow', 'Q3zXj3w').returns(false)
    assert_raises OAuth2::OAuth2Error::AccessDenied do
      request_handler.access_token_response(@mock_user)
    end
  end

  def test_should_return_token_hash_with_grant_type_password_and_valid_credentials
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :username => 'blackbeard',
                        :password => '$3Rdj@w',
                        :grant_type => 'password',
                        :state => @state,
                        :scope => @scope
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    @config.user_datastore.expects(:authenticate).with('blackbeard', '$3Rdj@w').returns(@mock_user)
    @config.token_datastore.expects(:generate_token).with(@client_app, @mock_user, {:scope => 'scope1 scope2'}).returns(@token)
    assert_equal @token_response, request_handler.access_token_response(@mock_user)
  end

  def test_should_return_throw_error_with_grant_type_refresh_token_and_invalid_refresh_token
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => "bogus"
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    @config.token_datastore.expects(:from_refresh_token).with('bogus').returns(nil)
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request_handler.access_token_response
    end
  end

  def test_should_return_access_token_with_grant_type_refresh_token_and_valid_refresh_token
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => @refresh_token
                        })
    request_handler = OAuth2::Server::RequestHandler.new(request)
    @config.token_datastore.expects(:from_refresh_token).with(@refresh_token).returns(@token)
    assert_equal @token_response, request_handler.access_token_response
  end
end