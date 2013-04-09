$:.unshift File.expand_path('../../examples', __FILE__)

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

require 'oauth2'
require 'rspec'
require 'rspec/autorun'
require 'webmock/rspec'

WebMock.disable_net_connect!(:allow => 'coveralls.io')

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