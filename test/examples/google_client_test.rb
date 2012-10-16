class GoogleClientTest < Test::Unit::TestCase

  def setup
    @google_client = GoogleClient.new(:filename => client_config_file, :service => :google, :env => :test)
    @redirect_uri = "http://localhost"
    @http_reponse = mock()
  end
  #
  # https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl
  def test_webserver_authorization_url_with_scope_as_string
    params = {
        :client_id => @google_client.client_id,
        :scope => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
        :state => '/profile',
        :redirect_uri => @redirect_uri,
        :approval_prompt => 'force',
        :response_type => 'code',
        :access_type => 'offline'
      }
    uri = @google_client.webserver_authorization_url(
        :scope => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
        :state => '/profile',
        :redirect_uri => @redirect_uri,
        :approval_prompt => 'force',
        :access_type => 'offline'
    )
    parsed_uri = Addressable::URI.parse(uri)
    assert_equal '/o/oauth2/auth', parsed_uri.path
    assert_equal params, parsed_uri.query_values.symbolize_keys
    assert_equal 'https', parsed_uri.scheme
    assert_equal 'accounts.google.com', parsed_uri.host
  end

  def test_webserver_authorization_url_with_scope_as_array
    params = {
        :client_id => @google_client.client_id,
        :scope => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
        :state => '/profile',
        :redirect_uri => @redirect_uri,
        :response_type => 'code'
      }
    uri = @google_client.webserver_authorization_url(
        :scope => [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile'
        ],
        :state => '/profile',
        :redirect_uri => @redirect_uri,
        :approval_prompt => 'force'
    )
    parsed_uri = Addressable::URI.parse(uri)
    assert_equal '/o/oauth2/auth', parsed_uri.path
    assert_equal params, parsed_uri.query_values.symbolize_keys
    assert_equal 'https', parsed_uri.scheme
    assert_equal 'accounts.google.com', parsed_uri.host
  end

  def test_webserver_authorization_url_with_scope_as_array
    assert_raises ArgumentError do 
      uri = @google_client.webserver_authorization_url(
          :scope => {},
          :state => '/profile',
          :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
          :approval_prompt => 'force'
      )
    end
  end

  def test_webserver_flow_exchange_authorization_code_for_token
    @http_reponse.stubs(:code).returns('200')
    @http_reponse.stubs(:body).returns('')
    params = {
        :client_id => @google_client.client_id,
        :client_secret => @google_client.client_secret,
        :redirect_uri => 'https://localhost',
        :code => '4/Q34ceh9scGyyhdbINmFnShoUb6He.gqeUS2xLY3cSuJJVnL49Cc8UjOvQdAI'
      }
    query = Addressable::URI.form_encode(params)
    Net::HTTP.any_instance.expects(:post).returns(@http_reponse)
    response = @google_client.exchange_auth_code_for_token(
      :params => {
        :code => '4/dbB0-UD1cvrQg2EuEFtRtHwPEmvR.IrScsjgB5M4VuJJVnL49Cc8QdUjRdAI',
        :redirect_uri => @redirect_uri
      }
    )
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
    uri = @google_client.clientside_authorization_url(
        :scope => 'https://www.googleapis.com/auth/userinfo.email',
        :state => '/profile',
        :redirect_uri => 'https://oauth2-login-demo.appspot.com/token',
        :approval_prompt => 'force'
    )
    parsed_uri = Addressable::URI.parse(uri)
    assert_equal '/o/oauth2/auth', parsed_uri.path
    assert_equal params, parsed_uri.query_values.symbolize_keys
    assert_equal 'https', parsed_uri.scheme
    assert_equal 'accounts.google.com', parsed_uri.host
  end
end