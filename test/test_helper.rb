require 'test/unit'
require 'mocha'
require 'addressable/uri'
require 'oauth2'
# require 'google_client'
# require 'yammer_client'
require 'unit/client/grant_test'
require 'unit/client/connection_test'
require 'unit/client/client_test'
# require 'unit/examples/google_client_test'
# require 'unit/examples/yammer_client_test'

TEST_ROOT = File.dirname(__FILE__)

class MiniTest::Unit::TestCase
  include OAuth2Client::Helper
end