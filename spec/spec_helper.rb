$:.unshift File.expand_path('../../examples', __FILE__)

# require 'simplecov'
# SimpleCov.start

require 'rspec'
require 'rspec/autorun'
require 'webmock/rspec'
require 'oauth2'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def stub_delete(path)
  stub_request(:delete, 'https://example.com' + path)
end

def stub_get(path)
  stub_request(:get, 'https://example.com' + path)
end

def stub_post(path)
  stub_request(:post, 'https://example.com' + path)
end

def stub_put(path)
  stub_request(:put, 'https://example.com' + path)
end