require File.expand_path('../../../test_helper', __FILE__)

class AuthorizationCodeTest < Test::Unit::TestCase

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
      :scope => 'abc xyz',
      :state => 'state'
    }
    assert_equal 'scope=abc+xyz&state=state&response_type=code&client_id=s6BhdRkqt3', grant.query(params)
  end

  def test_authorization_code_grant_should_return_authorization_path
    grant = OAuth2Client::Grant::AuthorizationCode.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :response_type => 'code',
      :scope => 'abc xyz',
      :state => 'state'
    }
    assert_equal '/oauth/authorize?response_type=code&scope=abc+xyz&state=state&client_id=s6BhdRkqt3', grant.authorization_path(params)
  end

  def test_authorization_code_grant_should_send_request_through_http_connection
    grant = OAuth2Client::Grant::AuthorizationCode.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path)
    params = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :code => 'G3Y6jU3a',
      :grant_type => 'authorization_code',
      :scope => 'abc xyz',
      :state => 'state'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token('G3Y6jU3a', :params => {:scope => 'abc xyz', :state => 'state'})
  end
end