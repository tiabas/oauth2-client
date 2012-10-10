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

  def test_client_credentials_should_send_credentials_in_request_body
    grant = OAuth2Client::Grant::ClientCredentials.new(@http_cnxn,
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

  def test_client_credentials_should_send_credentials_in_request_headers
    grant = OAuth2Client::Grant::ClientCredentials.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :grant_type => 'client_credentials',
      :scope => 'abc xyz',
      :state => 'state'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token({:scope => 'abc xyz', :state => 'state'})
  end

end