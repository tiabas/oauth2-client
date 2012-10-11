class YammerClientTest < MiniTest::Unit::TestCase

  def setup
    @scheme         = 'https'
    @host           = 'yammer.com'
    @client_id      = 'ETSIMVSxmgZltijWZr0G6w'
    @client_secret  = '4hJZY88TCBB9q8IpkeualA2lZsUhOSclkkSKw3RXuE'
    opts = {
          :port           =>  443,
          :token_path     => '/oauth2/access_token',
          :authorize_path => '/dialog/oauth/'
        }
    @yammer_client  = YammerClient.new(@client_id, @client_secret, @scheme, @host, opts)
  end

  def test_webserver_authorization_url
    params = {
        :redirect_uri=>"http://localhost:3000",
        :response_type => 'code'
      }
    uri = @yammer_client.authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
  end

  def test_client_authorization_url
    params = {
        :redirect_uri=>"http://localhost:3000",
        :response_type => 'token'
      }
    uri = @yammer_client.authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
  end
end