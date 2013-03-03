lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'json'
  spec.add_dependency 'bcrypt-ruby', '~> 3.0.0'
  spec.add_dependency 'addressable'
  spec.add_development_dependency 'bundler', '~> 1.0'

  spec.name             = 'oauth2-client'
  spec.version          = OAuth2::Version
  spec.date             = %q{2013-03-03}
  spec.summary          = "OAuth2 client wrapper in Ruby"
  spec.description      = "Create quick and dirty OAuth2 clients"
  spec.authors          = ["Kevin Mutyaba"]
  spec.email            = %q{tiabasnk@gmail.com}
  spec.homepage         = 'http://tiabas.github.com/oauth2-client/'
  spec.files            = `git ls-files`.split("\n")
  spec.require_paths    = ['lib']
  spec.licenses         = ['MIT']
  spec.required_rubygems_version = '>= 1.3.6'
end