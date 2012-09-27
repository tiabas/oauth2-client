class GrantTest < MiniTest::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/oauth/authorize"
    @token_path     = "/oauth/token"
    @http_cnxn = mock()  
  end

  # def test_attempt_to_initialize_base_grant
  #   assert_raises NoMethodError do
  #     grant = OAuth2::Client::Grant::Base.new
  #   end
  # end

  def test_create_password_grant
    grant = OAuth2::Client::Grant::Password.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password',
      :scope => 'xyz abc'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token('johndoe', 'password', :scope => 'xyz abc')
  end

  def test_create_refresh_token_grant
    grant = OAuth2::Client::Grant::RefreshToken.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :refresh_token => '2YotnFZFEjr1zCsicMWpAA',
      :grant_type => 'refresh_token',
      :scope => 'abc xyz',
      :state => 'state'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token('2YotnFZFEjr1zCsicMWpAA', {:scope => 'abc xyz', :state => 'state'})
  end

  def test_create_client_credentials_grant
    grant = OAuth2::Client::Grant::ClientCredentials.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'client_credentials',
      :scope => 'abc xyz',
      :state => 'state'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token({:scope => 'abc xyz', :state => 'state'})
  end

  def test_create_authorization_code_grant
    grant = OAuth2::Client::Grant::AuthorizationCode.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :code => 'G3Y6jU3a',
      :grant_type => 'authorization_code',
      :scope => 'abc xyz',
      :state => 'state'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token('G3Y6jU3a', {:scope => 'abc xyz', :state => 'state'})
  end

  def test_implicit_grant_request_for_code
    grant = OAuth2::Client::Grant::AuthorizationCode.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :response_type => 'code',
      :scope => 'xyz',
      :state => 'abc xyz'
    }
    # assert_equal 'client_id=s6BhdRkqt3&scope=xyz&response_type=code', grant.to_query
    # assert_equal 'https://example.com/oauth/authorize?client_id=s6BhdRkqt3&response_type=code&scope=xyz', grant.authorization_url
    # assert_equal params, grant
    @http_cnxn.expects(:send_request).with(@authorize_path, params, 'get', {}).returns(true)
    grant.get_authorization_url({:scope => 'xyz', :state => 'abc xyz'})
  end

  def test_implicit_grant_request_for_token
    grant = OAuth2::Client::Grant::Implicit.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :response_type => 'token',
      :scope => 'xyz',
      :state => 'abc xyz'
    }
    assert_equal '/oauth/token?scope=xyz&state=abc+xyz&response_type=token&client_id=s6BhdRkqt3', grant.token_path({:scope => 'xyz', :state => 'abc xyz'})
    @http_cnxn.expects(:send_request).with(@authorize_path, params, 'get', {}).returns(true)
    grant.get_token({:scope => 'xyz', :state => 'abc xyz'})
  end
end