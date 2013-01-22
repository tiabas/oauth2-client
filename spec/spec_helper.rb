$:.unshift File.expand_path('../../examples', __FILE__)

# require 'simplecov'
# SimpleCov.start 

require 'rspec'
require 'rspec/autorun'
require 'oauth2'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end