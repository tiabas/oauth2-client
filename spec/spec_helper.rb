# unless ENV['CI']
#   require 'simplecov'
#   SimpleCov.start do
#     add_filter 'spec'
#   end
# end

require 'rspec'
require 'oauth2'
# require 'addressable/uri'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end