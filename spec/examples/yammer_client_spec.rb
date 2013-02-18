# class YammerClientTest < Test::Unit::TestCase

#   def setup
#     @yammer_client  = YammerClient.new(:filename => client_config_file, :service => :yammer, :env => :test)
#   end

#   def test_webserver_generate_authorization_code_grant_authorize_url
#     params = {
#         :client_id => @yammer_client.client_id,
#         :redirect_uri =>"http://localhost/oauth/cb",
#         :response_type => 'code'
#       }
#     uri = @yammer_client.webserver_authorization_url(:redirect_uri =>"http://localhost/oauth/cb")
#     parsed_uri = Addressable::URI.parse(uri)
#     assert_equal '/dialog/oauth/', parsed_uri.path
#     assert_equal params, parsed_uri.query_values.symbolize_keys
#     assert_equal 'https', parsed_uri.scheme
#     assert_equal 'www.yammer.com', parsed_uri.host
#   end

#   def test_webserver_generate_authorization_code_grant_token_url
#     params = {
#         :client_id => @yammer_client.client_id,
#         :client_secret => @yammer_client.client_secret,
#         :grant_type => "authorization_code",
#         :redirect_uri => "http://localhost/oauth/cb",
#         :code => 'aXW2c6bYz'
#       }
#     uri = @yammer_client.webserver_token_url(:code => 'aXW2c6bYz', :redirect_uri =>"http://localhost/oauth/cb")
#     parsed_uri = Addressable::URI.parse(uri)
#     assert_equal '/oauth2/access_token', parsed_uri.path
#     assert_equal params, parsed_uri.query_values.symbolize_keys
#     assert_equal 'https', parsed_uri.scheme
#     assert_equal 'www.yammer.com', parsed_uri.host
#   end

#   def test_client_generate_implicit_grant_token_url
#     params = {
#         :client_id => @yammer_client.client_id,
#         :redirect_uri=>"http://localhost/oauth/cb?state=%2Fprofile",
#         :response_type => 'token',
#       }
#     uri = @yammer_client.clientside_authorization_url(:redirect_uri =>"http://localhost/oauth/cb?state=%2Fprofile")
#     puts uri
#     parsed_uri = Addressable::URI.parse(uri)
#     assert_equal '/dialog/oauth/', parsed_uri.path
#     assert_equal params, parsed_uri.query_values.symbolize_keys
#     assert_equal 'https', parsed_uri.scheme
#     assert_equal 'www.yammer.com', parsed_uri.host
#   end
# end