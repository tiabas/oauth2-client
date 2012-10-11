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

  def test_refresh_token_should_send_client_credentials_in_request_headers
    grant = OAuth2Client::Grant::RefreshToken.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :refresh_token => '2YotnFZFEjr1zCsicMWpAA',
      :grant_type => 'refresh_token',
      :scope => 'abc xyz',
      :state => 'state'
    }
    headers = {
      'Authorization' => http_basic_encode(@client_id, @client_secret)
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', headers).returns(true)
    grant.get_token('2YotnFZFEjr1zCsicMWpAA', {:scope => 'abc xyz', :state => 'state'})
  end

  def test_refresh_token_should_send_client_credentials_in_request_body
    grant = OAuth2Client::Grant::RefreshToken.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :refresh_token => '2YotnFZFEjr1zCsicMWpAA',
      :grant_type => 'refresh_token',
      :scope => 'abc xyz',
      :state => 'state'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token('2YotnFZFEjr1zCsicMWpAA', {:scope => 'abc xyz', :state => 'state'})
  end
end