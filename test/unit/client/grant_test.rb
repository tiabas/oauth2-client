class GrantTest < MiniTest::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/oauth/authorize"
    @token_path     = "/oauth/token"
    @client = mock()
    @client.stubs(:client_id).returns(@client_id)
    @client.stubs(:client_secret).returns(@client_secret)
    @client.stubs(:scheme).returns(@scheme)
    @client.stubs(:host).returns(@host)
    @client.stubs(:authorize_path).returns(@authorize_path)
    @client.stubs(:token_path).returns(@token_path)  
  end

  # def test_attempt_to_initialize_base_grant
  #   assert_raises NoMethodError do
  #     grant = OAuth2::Client::Grant::Base.new
  #   end
  # end

  def test_nil_parameters_should_be_ignored

    grant = OAuth2::Client::Grant::Password.new(@client, 'johndoe', 'password',
                                                :password => nil,
                                                :scope => nil)
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password'
    }
    assert_equal result, grant

  end

  def test_optional_parameters_should_not_overwrite_required_parameters

    grant = OAuth2::Client::Grant::Password.new(@client, 'johndoe', 'password',
                                                :username => 'myname',
                                                :password => 'nopass',
                                                :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password',
      :scope => 'xyz'
    }
    assert_equal result, grant
  end

  def test_create_password_grant
    grant = OAuth2::Client::Grant::Password.new(@client, 'johndoe', 'password', :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password',
      :scope => 'xyz'
    }
    assert_equal result, grant
    @client.expects(:make_request).with(@token_path, result, 'post', {}).returns(true)
    grant.get_token
  end

  def test_create_refresh_token_grant
    grant = OAuth2::Client::Grant::RefreshToken.new(@client, '2YotnFZFEjr1zCsicMWpAA', :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :refresh_token => '2YotnFZFEjr1zCsicMWpAA',
      :grant_type => 'refresh_token',
      :scope => 'xyz'
    }
    assert_equal result, grant
    @client.expects(:make_request).with(@token_path, result, 'post', {}).returns(true)
    grant.get_token
  end

  def test_create_client_credentials_grant
    grant = OAuth2::Client::Grant::ClientCredentials.new(@client, :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'client_credentials',
      :scope => 'xyz'
    }
    assert_equal result, grant
    @client.expects(:make_request).with(@token_path, result, 'post', {}).returns(true)
    grant.get_token
  end

  def test_create_authorization_code_grant
    grant = OAuth2::Client::Grant::AuthorizationCode.new(@client, 'G3Y6jU3a', :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :code => 'G3Y6jU3a',
      :grant_type => 'authorization_code',
      :scope => 'xyz'
    }
    assert_equal result, grant
    @client.expects(:make_request).with(@token_path, result, 'post', {}).returns(true)
    grant.get_token
  end

  def test_implicit_grant_request_for_code
    grant = OAuth2::Client::Grant::Implicit.new(@client, 'code', :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :response_type => 'code',
      :scope => 'xyz'
    }
    assert_equal 'client_id=s6BhdRkqt3&scope=xyz&response_type=code', grant.to_query
    assert_equal 'https://example.com/oauth/authorize?client_id=s6BhdRkqt3&response_type=code&scope=xyz', grant.authorization_url
    assert_equal result, grant
    @client.expects(:make_request).with(@authorize_path, result, 'get', {}).returns(true)
    grant.get_authorization_uri
  end

  def test_implicit_grant_request_for_token
    grant = OAuth2::Client::Grant::Implicit.new(@client, 'token', :scope => 'xyz')
    result = {
      :client_id => @client_id,
      :response_type => 'token',
      :scope => 'xyz'
    }
    assert_equal 'client_id=s6BhdRkqt3&scope=xyz&response_type=token', grant.to_query
    assert_equal 'https://example.com/oauth/authorize?client_id=s6BhdRkqt3&response_type=token&scope=xyz', grant.authorization_url
    assert_equal result, grant
    @client.expects(:make_request).with(@authorize_path, result, 'get', {}).returns(true)
    grant.get_authorization_uri
  end
end