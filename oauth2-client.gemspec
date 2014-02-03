lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2-client/version'

Gem::Specification.new do |spec|


  spec.authors          = ["Kevin Mutyaba"]
  spec.date             = Date.today.to_s
  spec.description      = "Create quick and dirty OAuth2 clients"
  spec.email            = %q{tiabasnk@gmail.com}
  spec.files            = `git ls-files`.split("\n")
  spec.homepage         = 'http://tiabas.github.com/oauth2-client/'
  spec.licenses         = ['MIT']
  spec.name             = 'oauth2-client'
  spec.require_paths    = ['lib']
  spec.required_rubygems_version = '>= 1.3'
  spec.summary          = "OAuth2 client wrapper in Ruby"
  spec.version          = OAuth2Client::Version

  spec.cert_chain       = ['certs/tiabas-public.pem']
  spec.signing_key      = File.expand_path("~/.gem/certs/private_key.pem") if $0 =~ /gem\z/

  spec.add_dependency 'addressable', '~> 2.3'
  spec.add_dependency 'bcrypt-ruby', '~> 3.0'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov', '~> 0.7'
  spec.add_development_dependency 'webmock', '~> 1.9'
  spec.add_development_dependency 'coveralls', '~>0.7'
end
