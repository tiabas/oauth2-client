class RequestTest < MiniTest::Unit::TestCase
  
  def setup
    @code = 'G3Y6jU3a'
    @client_id = 's6BhdRkqt3'
    @client_secret = 'SplxlOBeZQQYbYS6WxSbIA'
    @access_token = '2YotnFZFEjr1zCsicMWpAA'
    @refresh_token = 'tGzv3JOkF0XG5Qx2TlKWIA'
    @expires_in = 3600
    @token_type = 'bearer'
    @redirect_uri = create_redirect_uri
    @token_response = {
                        :access_token => @access_token,
                        :refresh_token => @refresh_token,
                        :token_type => @token_type,
                        :expires_in =>  @expires_in,
                      }
    @request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
  end

  def test_should_return_client_with_valid_client_id
    assert @request.validate_client_id
  end

  def test_should_raise_invalid_request_error_with_missing_response_type
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_response_type
    end 
  end

  def test_should_raise_unsupported_response_type_with_invalid_response_type
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :response_type => 'fake',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::UnsupportedResponseType do
      request.validate_response_type
    end 
  end

  def test_should_raise_invalid_request_error_with_missing_grant_type
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => nil,
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_grant_type
    end 
  end

  def test_should_raise_unsupported_grant_type_with_invalid_grant_type
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'fake',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::UnsupportedGrantType do
      request.validate_grant_type
    end 
  end

  # Response type: code
  def test_should_raise_invalid_request_when_response_type_code_and_invalid_redirect_uri
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'code',
                        :redirect_uri => 'ftp://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_redirect_uri
    end
  end

  def test_should_pass_validation_when_response_type_code_and_redirect_uri_nil
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'code',
                        :state => 'xyz'
                        })
    assert_equal nil, request.validate_redirect_uri
  end

  def test_should_pass_validation_when_response_type_code_and_valid_redirect_uri
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'code',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert request.validate_redirect_uri
  end
  ###

  # Response type: token
  def test_should_raise_invalid_request_when_response_type_token_and_invalid_redirect_uri
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :redirect_uri => 'ftp://client.example2.com/oauth_v2/cb',
                        :state => 'xyz'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_redirect_uri
    end
  end

  def test_should_pass_validation_when_response_type_token_and_redirect_uri_nil
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :state => 'xyz'
                        })
    assert true, request.validate_redirect_uri
  end

  def test_should_pass_validation_when_response_type_code_and_valid_redirect_uri
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'token',
                        :redirect_uri => @redirect_uri,
                        :state => 'xyz'
                        })
    assert request.validate_redirect_uri
  end

  # Grant type: password
  def test_should_raise_invalid_request_with_username_and_password_missing_and_grant_type_is_password
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_user_credentials
    end
  end

  def test_should_raise_invalid_request_with_grant_type_password_and_password_missing
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri,
                        :username => 'benutzername'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_user_credentials
    end
  end

  def test_should_raise_invalid_request_with_grant_type_password_and_username_missing
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri,
                        :password => 'kennwort'
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_user_credentials
    end
  end

  def test_should_pass_with_grant_type_password_and_valid_username_and_password
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'password',
                        :redirect_uri => @redirect_uri,
                        :username => 'benutzername',
                        :password => 'passwort'
                        })
    assert request.validate_user_credentials
  end

  # Grant type: client_credentials
  def test_should_raise_invalid_request_with_grant_type_client_credentials_and_client_secret_missing
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'client_credentials',
                        :redirect_uri => @redirect_uri
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_client_credentials
    end
  end

  def test_should_pass_with_with_grant_type_client_credentials_and_valid_client_secret
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'client_credentials',
                        :redirect_uri => @redirect_uri,
                        :client_secret => @client_secret
                        })
    assert request.validate_client_credentials
  end

  # Grant type: authorization_code
  def test_should_raise_invalid_request_with_grant_type_client_credentials_but_no_code
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_authorization_code
    end
  end

  def test_should_pass_with_grant_type_client_credentials_and_code
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'authorization_code',
                        :redirect_uri => @redirect_uri,
                        :code => @code
                        })
    assert request.validate_authorization_code
  end

  # Grant type: refresh_token
  def test_should_raise_invalid_request_with_grant_type_refresh_token_but_no_refresh_token
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        })
    assert_raises OAuth2::OAuth2Error::InvalidRequest do
      request.validate_refresh_token
    end
  end

  def test_should_pass_with_grant_type_refresh_token_and_refresh_token
    request = OAuth2::Server::Request.new({
                        :client_id => @client_id,
                        :grant_type => 'refresh_token',
                        :refresh_token => @refresh_token
                        })
    assert request.validate_refresh_token
  end
end