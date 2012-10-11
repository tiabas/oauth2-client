class ImplicitTest < MiniTest::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/oauth/authorize"
    @token_path     = "/oauth/token"
    @http_cnxn = mock()  
  end

  def test_implicit_grant_request_for_code
    grant = OAuth2Client::Grant::AuthorizationCode.new(@http_cnxn,
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
    @http_cnxn.expects(:send_request).with(@authorize_path, params, 'get', {}).returns(true)
    grant.get_authorization_url({:scope => 'xyz', :state => 'abc xyz'})
  end

  def test_implicit_grant_request_for_token
    grant = OAuth2Client::Grant::Implicit.new(@http_cnxn,
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