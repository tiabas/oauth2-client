require 'test/unit'
require 'mocha'
require 'addressable/uri'
require 'active_support/all'
require 'oauth2'
require 'examples'

TEST_ROOT = File.dirname(__FILE__)

module OAuth2ClientsHelper
  def client_config
    File.join(TEST_ROOT, 'mocks/oauth_client.yml')
  end
end

class Test::Unit::TestCase
  include OAuth2Client::Helper
  include OAuth2ClientsHelper
  extend  OAuth2ClientsHelper
end