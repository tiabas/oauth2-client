class GoogleClientTest < MiniTest::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'accounts.google.com'
    @client_id      = '812741506391.apps.googleusercontent.com'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @authorize_path = "/o/oauth2/auth"
    @token_path     = "/o/oauth2/token"
    opts = {
          :port           =>  443,
          :token_path     => '/o/oauth2/token',
          :authorize_path => '/o/oauth2/auth'
        }
    @google_client = GoogleClient.new(@client_id, @client_secret, @scheme, @host, opts)
  end

  def test_webserver_authorization_url
    params = {
        :scope=> 'https://www.googleapis.com/auth/userinfo.email',
        :state=> '/profile',
        :redirect_uri=> 'https://oauth2-login-demo.appspot.com/code',
        :approval_prompt=> 'force',
        :response_type => 'code'
      }
    uri = @google_client.authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
  end

  def test_client_authorization_url
    params = {
        :scope=> 'https://www.googleapis.com/auth/userinfo.email',
        :state=> '/profile',
        :redirect_uri=> 'https://oauth2-login-demo.appspot.com/token',
        :approval_prompt=> 'force',
        :response_type => 'token'
      }
    uri = @google_client.authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
  end

  def test_login_authorization_url
    params = {
        :scope=> 'https://www.googleapis.com/auth/userinfo.email',
        :state=> '/profile',
        :redirect_uri=> 'https://oauth2-login-demo.appspot.com/oauthcallback',
        :approval_prompt=> 'force',
        :response_type => 'token'
      }
    uri = @google_client.authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
  end
end