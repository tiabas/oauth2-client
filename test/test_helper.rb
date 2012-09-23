require 'test/unit'
require 'mocha'
require 'oauth2'
# require 'unit/client/grant_test'
# require 'unit/client/connection_test'
# require 'unit/client/client_test'
# require 'unit/client/google_client_test'
require 'unit/client/yammer_client_test'
# require 'unit/server/request_test'
# require 'unit/server/request_handler_test'

TEST_ROOT = File.dirname(__FILE__)

class MiniTest::Unit::TestCase
  def create_redirect_uri
    return 'https://client.example.com/oauth_v2/cb'
  end
end