# OAuth2 Client Ruby

[![Gem Version](https://badge.fury.io/rb/oauth2-client.png)][gem]
[![Build Status](https://secure.travis-ci.org/tiabas/oauth2-client.png?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/tiabas/oauth2-client.png)][gemnasium]
[![Coverage Status](https://coveralls.io/repos/tiabas/oauth2-client/badge.png?branch=master)][coveralls]

[gem]: https://rubygems.org/gems/oauth2-client
[travis]: http://travis-ci.org/tiabas/oauth2-client
[gemnasium]: https://gemnasium.com/tiabas/oauth2-client
[coveralls]: https://coveralls.io/r/tiabas/oauth2-client

A Ruby wrapper based on the OAuth 2.0 specification for build oauth2 clients. It is designed with the philosophy that 
many oauth2 providers implement OAuth 2.0 differently and not exactly according to the
[RFC]( http://tools.ietf.org/html/rfc6749). With this gem, a developer has some degree of flexibilty in creating a 
client that will work with different OAuth2 providers. This flexibilty comes at the same price of having to implement 
a few things yourself. To that effect, an access token response is returned as an HTTPResponse from which the response
body can be extracted. It turns out that not every oauth2 providers returns tokens in the same format. Therefore, rather 
than make assumptions about the token response, this gem leaves that responsiblity to the developer.

Bundled with the gem are working sample clients for Google, Yammer and Github. The structure of the clients is easy to 
follow thus making it possible to simply copy code from one client and simply substitute the rights credentials and request
URL paths.

For more about the standard checkout: http://tools.ietf.org/html/rfc6749 

## Installation
```sh
gem install oauth2-client
```

## Resources
* [View Source on GitHub][code]
* [Report Issues on GitHub][issues]
* [Website][website]

[website]: http://tiabas.github.com/oauth2-client/
[code]: https://github.com/tiabas/oauth2-client
[issues]: https://github.com/tiabas/oauth2-client/issues

## Usage Examples

```ruby
require 'oauth2'

@client  = OAuth2::Client.new('https://example.com', 's6BhdRkqt3', '4hJZY88TCBB9q8IpkeualA2lZsUhOSclkkSKw3RXuE')

client.authorization_code.authorization_path(:redirect_uri => 'http://localhost/oauth2/cb')
# => "/oauth/authorize?response_type=code&client_id={client_id}&redirect_uri=http%3A%2F%2Flocalhost%2Foauth2%2Fcb"

```

## Authorization Grants
The client wraps around the creation of any given grant and passing in the parameters defined in the configuration
file. The supported grants include Authorization Code, Implicit, Resource Owner Password Credentials, Client Credentials.
There is also support for device authentication as described in Google's OAuth 2.0 authentication methods(https://developers.google.com/accounts/docs/OAuth2ForDevices). They are available via the `authorization_code`, `implicit`, `password`, `client_credentials`, `refresh_token`
and `device` methods on a client object.

The `get_token` method on the grants does not make any assumptions about the format ofthe response from the OAuth provider. The ideal
case would be to treat all responses as JSON. However, some services may respond with in XML instead of JSON. The `get_token` method
therefore, returns with an HTTPResponse object.

### Authorization Code
```ruby
auth_url = client.authorization_code.authorization_path(:redirect_uri => 'http://localhost/oauth2/cb')
# => "/oauth/authorize?response_type=code&client_id={client_id}&redirect_uri=http%3A%2F%2Flocalhost%2Foauth2%2Fcb"

token_url = client.authorization_code.token_path(
    :code => aXW2c6bYz, 
    :redirect_uri => 'http://localhost/oauth2/cb')
# => "/oauth/token?redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&client_secret={client_secret}&grant_type=authorization_code&client_id={client_id}&code=aXW2c6bYz"
```

### Implicit Grant
```ruby
auth_url = client.implicit.authorization_path(:redirect_uri => 'http://localhost/oauth2/cb')
# => "oauth/?redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&response_type=token&client_id={client_id}"
```

### Password Credentials
```ruby
token = client.password.get_token('username', 'password')
```

### Refresh Token
```ruby
token = client.refresh_token.get_token(refresh_token_value, :params => {:scope => 'abc xyz', :state => 'state'})
```

### Client Credentials
```ruby
token = client.client_credentials.get_token
```

### Device Code
```ruby
auth_url = client.device_code.authorization_path(:scope => 'abc xyz', :state => 'state')
# => "/oauth/device/code?scope=abc+xyz&state=state&client_id={client_id}"

# exchange device authorization code for access token
token = client.device_code.get_token(device_auth_code)
```

# Using a custom Http wrapper
By default, oauth2-client uses a `Net::HTTP` wrapper called `OAuth2::HttpConnection`. However, if you wish to use a different HTTP library, you only
need to create a wrapper around your favorite library that will respond to the `send_request` method.

```ruby
class TyphoeusHttpConnection
  
  def initialize(site_url, connection_options={})
    # set url and connection options
    @site_url = site_url
    @connection_options = connection_options
  end

  def base_url(path)
    @site_url + path
  end

  def send_request(http_method, request_path, options={})
    # options may contain optional arguments like http headers, request parameters etc
    # send http request over the inter-webs

    params          = options[:params] || {}
    headers         = options[:headers]|| {}
    method          = method.to_sym
    client          = Typhoeus

    case method
    when :get, :delete
      #pass
    when :post, :put
      options[:body] = options.delete(:params) if options[:params]
    else
      raise UnhandledHTTPMethodError.new("Unsupported HTTP method, #{method}")
    end
    response = client.send(http_method, base_url(request_path), params)
  end
end

# now you can initialize the OAuth2 client with you custom client and expect that all requests
# will be sent using this client
oauth_client = OAuth2::Client.new('example.com', client_id, client_secret, {
  :connection_client  => TyphoeusHttpConnection,
  :connection_options => {}
})
```

# Client Examples
This library comes bundled with two sample implementations of Google and Yammer OAuth clients. These clients are 
meant to showcase the degree of flexibilty that you get when using this library to interact with other OAuth 2.0
providers.

## Google Client

```ruby

google_client = GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com','a2nQpcUm2Dgq1chWdAvbXGTk')

```

### Client-side authorization URL(Implicit grant)
```ruby

# generate authorization url
auth_url = google_client.webserver_authorization_url(
    :scope => 'https://www.googleapis.com/auth/userinfo.email',
    :state => '/profile',
    :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
    :approval_prompt => 'force')
# => https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&state=%2Fprofile&redirect_uri=https%3A%2F%2Foauth2-login-demo.appspot.com%2Ftoken&approval_prompt=force&response_type=token&client_id=812741506391.apps.googleusercontent.com
```

### Server-side authorization URL(Authorization code grant)
```ruby

# generate authorization url
auth_url = google_client.clientside_authorization_url(
    :scope => 'https://www.googleapis.com/auth/userinfo.email',
    :state => '/profile',
    :redirect_uri => 'http://localhost/oauth/code',
    :approval_prompt => 'force')
# => https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&state=%2Fprofile&redirect_uri=https%3A%2F%2Foauth2-login-demo.appspot.com%2Fcode&approval_prompt=force&response_type=code&client_id=812741506391.apps.googleusercontent.com

# exchange authorization code for access token. we will get back a Net::HTTPResponse
response = google_client.exchange_auth_code_for_token(
  :params => {
    :code => '4/dbB0-UD1cvrQg2EuEFtRtHwPEmvR.IrScsjgB5M4VuJJVnL49Cc8QdUjRdAI',
    :redirect_uri => 'http://localhost/oauth/token'
  }
)
response.inspect 
# => #<Net::HTTPOK:0x007ff8bc7c1200>

response.body
# => {
#  "access_token" : "ya91.AHES8ZS-oCZnc5yHepnsosFjNln9ZKLuioF6FcMRCGUIzA",
#  "token_type" : "Bearer",
#  "expires_in" : 3600,
#  "id_token" : "eyJhbGciOiJSUzI1NiIsImtpZCI6IjY4ZGM2ZmIxNDQ5OGJmMWRhNjNiMWYyMDA2YmRmMDA2N2Q4MzY",
#  "refresh_token" : "6/Ju8uhi9xOctGEyHRzWwHhaYimfxmY0tiJ_qW3qvjWXM"
#}
```

## Github Client

```ruby

gihub_client = GithubClient.new('https://github.com', '82f971d013e8d637a7e1', '1a1d59e1f8b8afa5f73e9dc9f17e25f7876e64ac')

```
### Server-side authorization URL(Authorization code grant)

```ruby

# generate authorization url
auth_url = gihub_client.webserver_authorization_url
# => https://github.com/login/oauth/authorize?client_id=82f971d013e8d637a7e1&response_type=code

# exchange authorization code for access token. we will get back a Net::HTTPResponse
response = gihub_client.exchange_auth_code_for_token({
    :code => '11a0b0b64db56c30e2ef',
    :redirect_uri => 'https://localhost/callback',
  })

response.inspect 
# => #<Net::HTTPOK:0x007ff8bc7c1200>

response.body
# => {
#      "access_token" : "e409f4272fe539166a77c42479de030e7660812a",
#      "token_type" : "bearer"
#    }"
```

## Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
version:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

## Copyright
Copyright (c) 2013 Kevin Mutyaba
See [LICENSE][license] for details.
[license]: https://github.com/tiabas/oauth2-client/blob/master/LICENSE