class GoogleClientTest < Test::Unit::TestCase

  def setup
    @google_client = GoogleClient.new(:filename => client_config_file, :service => :google, :env => :test)
  end
  #
  # https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl
  def test_webserver_authorization_url
    params = {
        :client_id => @google_client.client_id,
        :scope => 'https://www.googleapis.com/auth/userinfo.email',
        :state => '/profile',
        :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
        :approval_prompt => 'force',
        :response_type => 'code'
      }
    uri = @google_client.webserver_authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
    assert_equal '/o/oauth2/auth', parsed_uri.path
    assert_equal params, parsed_uri.query_values.symbolize_keys
    # assert_equal 'https', parsed_uri.scheme
    # assert_equal 'accounts.google.com', parsed_uri.host
  end

  def test_client_authorization_url
    params = {
        :client_id => @google_client.client_id,
        :scope => 'https://www.googleapis.com/auth/userinfo.email',
        :state => '/profile',
        :redirect_uri => 'https://oauth2-login-demo.appspot.com/token',
        :approval_prompt => 'force',
        :response_type => 'token'
      }
    uri = @google_client.clientside_authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
    assert_equal '/o/oauth2/auth', parsed_uri.path
    assert_equal params, parsed_uri.query_values.symbolize_keys
    # assert_equal 'https', parsed_uri.scheme
    # assert_equal 'accounts.google.com', parsed_uri.host
  end
end