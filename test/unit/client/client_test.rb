class ClientTest < MiniTest::Unit::TestCase

  def setup
    @client_id = 's6BhdRkqt3'
    @client_secret = '4hJZY88TCBB9q8IpkeualA2lZsUhOSclkkSKw3RXuE'
    @host = 'server.example.com' 
    @scheme = 'https'
    @token_path = '/oauth/token'
    @authorize_path = '/oauth/authorize'
    @http_connection = mock()
    @config = mock()

    @config.stubs(:client_id).returns(@client_id)
    @config.stubs(:client_secret).returns(@client_secret)
    @config.stubs(:scheme).returns(@scheme)
    @config.stubs(:host).returns(@host)
    @config.stubs(:port).returns(443)
    @config.stubs(:authorize_path).returns(@authorize_path)
    @config.stubs(:token_path).returns(@token_path)
    @config.stubs(:http_client).returns(mock())

    @client = OAuth2Client::Client.new(@config)
    @client.stubs(:http_connection).returns(@http_connection)
  end

  def test_implicit_grant_token_request
    auth = @client.implicit
    params = {
      :client_id => @client_id ,
      :response_type => 'token',
      :redirect_uri => 'http://client.example.com/oauth/v2/callback'
    }
    @http_connection.expects(:send_request).with('/oauth/authorize', params, 'get', {}).returns(true)
    auth.get_token(:redirect_uri => 'http://client.example.com/oauth/v2/callback')
  end

  def test_authorization_code_grant_code_request
    auth = @client.authorization_code
    params = {
      :client_id => @client_id ,
      :response_type => 'code',
      :redirect_uri => 'http://client.example.com/oauth/v2/callback'
    }
    @http_connection.expects(:send_request).with('/oauth/authorize', params, 'get', {}).returns(true)
    auth.get_authorization_url(:redirect_uri => 'http://client.example.com/oauth/v2/callback')
  end

  def test_authorization_code_grant
    auth = @client.authorization_code
    params = {
      :client_id => @client_id ,
      :code => 'SplxlOBeZQQYbYS6WxSbIA',
      :grant_type => 'authorization_code' 
    }
    @http_connection.expects(:send_request).with('/oauth/token', params, 'post', {}).returns(true)
    auth.get_token('SplxlOBeZQQYbYS6WxSbIA')
  end

  def test_resource_owner_password_credentials_grant
    auth = @client.password
    params = {
      :client_id => @client_id ,
      :username => 'johndoe',
      :password => 'A3ddj3w',
      :grant_type => 'password' 
    }
    @http_connection.expects(:send_request).with('/oauth/token', params, 'post', {}).returns(true)
    auth.get_token('johndoe', 'A3ddj3w')
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
    auth = @client.refresh_token
    params = {
      :client_id => @client_id ,
      :refresh_token => 'tGzv3JOkF0XG5Qx2TlKWIA',
      :grant_type => 'refresh_token' 
    }
    @http_connection.expects(:send_request).with('/oauth/token', params, 'post', {}).returns(true)
    auth.get_token('tGzv3JOkF0XG5Qx2TlKWIA')
  end
end