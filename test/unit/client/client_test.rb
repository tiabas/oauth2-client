class OAuth2ClientTest < MiniTest::Unit::TestCase

  def setup
    @client_id = 's6BhdRkqt3'
    @client_secret = '4hJZY88TCBB9q8IpkeualA2lZsUhOSclkkSKw3RXuE'
    @host = 'server.example.com' 
    @scheme = 'https'
    @client = OAuth2::Client::Client.new(@client_id, @client_secret, @scheme, @host)
    @http_connection = mock()
    @client.expects(:http_connection).returns(@http_connection)
  end

  def test_implicit_grant_code_request
    auth = @client.implicit('code', :redirect_uri => 'http://client.example.com/oauth/v2/callback')
    params = {
      :client_id => @client_id ,
      :response_type => 'code',
      :redirect_uri => 'http://client.example.com/oauth/v2/callback'
    }
    @http_connection.expects(:send_request).with('/oauth/authorize', params, 'get', {}).returns(true)
    auth.get_authorization_uri
  end

  def test_implicit_grant_token_request
    auth = @client.implicit('token', :redirect_uri => 'http://client.example.com/oauth/v2/callback')
    params = {
      :client_id => @client_id ,
      :response_type => 'token',
      :redirect_uri => 'http://client.example.com/oauth/v2/callback'
    }
    @http_connection.expects(:send_request).with('/oauth/authorize', params, 'get', {}).returns(true)
    auth.get_authorization_uri
  end

  def test_authorization_code_grant
    auth = @client.authorization_code('SplxlOBeZQQYbYS6WxSbIA')
    params = {
      :client_id => @client_id ,
      :client_secret => @client_secret,
      :code => 'SplxlOBeZQQYbYS6WxSbIA',
      :grant_type => 'authorization_code' 
    }
    @http_connection.expects(:send_request).with('/oauth/token', params, 'post', {}).returns(true)
    auth.get_token
  end

  def test_resource_owner_password_credentials_grant
    auth = @client.password('johndoe', 'A3ddj3w')
    params = {
      :client_id => @client_id ,
      :client_secret => @client_secret,
      :username => 'johndoe',
      :password => 'A3ddj3w',
      :grant_type => 'password' 
    }
    @http_connection.expects(:send_request).with('/oauth/token', params, 'post', {}).returns(true)
    auth.get_token
  end

  def test_client_credentials_grant
    auth = @client.client_credentials
    params = {
      :client_id => @client_id ,
      :client_secret => @client_secret,
      :grant_type => 'client_credentials' 
    }
    @http_connection.expects(:send_request).with('/oauth/token', params, 'post', {}).returns(true)
    auth.get_token
  end

  def test_refresh_token_grant
    auth = @client.refresh_token('tGzv3JOkF0XG5Qx2TlKWIA')
    params = {
      :client_id => @client_id ,
      :client_secret => @client_secret,
      :refresh_token => 'tGzv3JOkF0XG5Qx2TlKWIA',
      :grant_type => 'refresh_token' 
    }
    @http_connection.expects(:send_request).with('/oauth/token', params, 'post', {}).returns(true)
    auth.get_token
  end
end