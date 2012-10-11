class YammerClientTest < Test::Unit::TestCase

  def setup
    yam_conf = OAuth2Client::Config.new(:filename => client_config, :service => :yammer, :env => :test)
    @yammer_client  = YammerClient.new(yam_conf)
  end

  def test_webserver_authorization_url
    params = {
        :client_id => @yammer_client.client_id,
        :redirect_uri =>"http://localhost:3000",
        :response_type => 'code'
      }
    uri = @yammer_client.webserver_authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
    assert_equal '/dialog/oauth/', parsed_uri.path
    assert_equal params, parsed_uri.query_values.symbolize_keys
  end

  def test_client_authorization_url
    params = {
        :client_id => @yammer_client.client_id,
        :redirect_uri=>"http://localhost:3000",
        :response_type => 'token'
      }
    uri = @yammer_client.client_side_authorization_url(params)
    parsed_uri = Addressable::URI.parse(uri)
    assert_equal '/dialog/oauth/', parsed_uri.path
    assert_equal params, parsed_uri.query_values.symbolize_keys
  end
end