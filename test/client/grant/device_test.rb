require File.expand_path('../../../test_helper', __FILE__)

class DeviceTest < Test::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/oauth/authorize"
    @token_path     = "/oauth/token"
    @device_path    = "/oauth/device/code"
    @http_cnxn = mock()
  end

  def test_device_grant_should_return_authorization_query_parameters
    grant = OAuth2Client::Grant::Device.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path,
                                :device_path => @device_path)
    params = {
      :scope => 'abc xyz',
      :state => 'state'
    }
    assert_equal 'scope=abc+xyz&state=state&client_id=s6BhdRkqt3', grant.query(params)
  end

  def test_device_grant_should_authorization_path
    grant = OAuth2Client::Grant::Device.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path,
                                :device_path => @device_path)
    params = {
      :scope => 'abc xyz',
      :state => 'state'
    }
    assert_equal '/oauth/device/code?scope=abc+xyz&state=state&client_id=s6BhdRkqt3', grant.authorization_path(params)
  end

  def test_device_grant_should_send_request_through_http_connection
    grant = OAuth2Client::Grant::Device.new(@http_cnxn,
                                :client_id => @client_id,
                                :client_secret => @client_secret,
                                :token_path => @token_path,
                                :authorize_path => @authorize_path,
                                :device_path => @device_path)

    params = {
      :client_id => @client_id,
      :client_secret => @client_secret,
      :code => '4L9fTtLrhY96442SEuf1Rl3KLFg3y',
      :grant_type => 'http://oauth.net/grant_type/device/1.0',
      :scope => 'abc xyz',
      :state => 'state'
    }
    @http_cnxn.expects(:send_request).with(@token_path, params, 'post', {}).returns(true)
    grant.get_token('4L9fTtLrhY96442SEuf1Rl3KLFg3y', :params => {:scope => 'abc xyz', :state => 'state'})
  end
end