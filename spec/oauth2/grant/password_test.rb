require File.expand_path('../../../test_helper', __FILE__)

class PasswordTest < Test::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/oauth/authorize"
    @token_path     = "/oauth/token"
    @http_cnxn = mock()  
  end

  def test_password_grant_should_send_client_credentials_in_request_headers
    grant = OAuth2Client::Grant::Password.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password',
      :scope => 'xyz abc'
    }
    headers = {
      'Authorization' => http_basic_encode(@client_id, @client_secret)
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', headers).returns(true)
    grant.get_token('johndoe', 'password', :params => {:scope => 'xyz abc'}, :auth_type => :header)
  end

  def test_password_grant_should_send_client_credentials_in_request_body
    grant = OAuth2Client::Grant::Password.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :grant_type => 'password',
      :username => 'johndoe',
      :password => 'password',
      :scope => 'xyz abc'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token('johndoe', 'password', :params => {:scope => 'xyz abc'})
  end
end