class AuthorizationCodeTest < MiniTest::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/oauth/authorize"
    @token_path     = "/oauth/token"
    @http_cnxn = mock()  
  end

  def test_authorization_code_grant_should_return_query_parameters
    grant = OAuth2Client::Grant::AuthorizationCode.new(@http_cnxn,
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
    assert_equal 'client_id=s6BhdRkqt3&response_type=code&scope=abc+xyz&state=state', grant.to_query
  end

  def test_authorization_code_grant_should_return_authorization_path
    grant = OAuth2Client::Grant::AuthorizationCode.new(@http_cnxn,
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
    assert_equal '/oauth/authorize?client_id=s6BhdRkqt3&response_type=code&scope=abc+xyz&state=state', grant.authorization_path
  end

  def test_authorization_code_grant_should_send_request_through_http_connection
    grant = OAuth2Client::Grant::AuthorizationCode.new(@http_cnxn,
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