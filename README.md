# OAuth2 Ruby Client

[![Build Status](https://secure.travis-ci.org/tiabas/oauth2-client.png?branch=master)][travis]

[travis]: http://travis-ci.org/tiabas/oauth2-client

A Ruby wrapper for the OAuth 2.0 specification. It is designed with the philosophy that not
every service that claims to support OAuth 2.0 actually implements it according to the
[standard]( http://tools.ietf.org/html/rfc6749). This version therefore, affords 
the developer some degree of flexibility in generating the URLs and requests
needed to authorize an OAuth 2.0 application.

For more about the standard, take a look at http://tools.ietf.org/html/rfc6749 

## Installation
Download the library and include the its location in your Gemfile

## Resources
* [View Source on GitHub][code]
* [Report Issues on GitHub][issues]

[code]: https://github.com/tiabas/oauth2-client
[issues]: https://github.com/tiabas/oauth2-client/issues

## Usage Examples

```ruby
require 'oauth2-client'

@client  = OAuth2::Client.new('https://example.com', 's6BhdRkqt3', '4hJZY88TCBB9q8IpkeualA2lZsUhOSclkkSKw3RXuE')

client.authorization_code.authorization_path(:redirect_uri => 'http://localhost/oauth2/cb')
# => "/oauth/authorize?response_type=code&client_id={client_id}&redirect_uri=http%3A%2F%2Flocalhost%2Foauth2%2Fcb"

```

## Authorization Grants
The client wraps around the creation of any given grant and passing in the parameters defined in the configuration
file. The supported grants include Authorization Code, Implicit, Resource Owner Password Credentials, Client Credentials.
There is also support for device authentication as described in Google's OAuth 2.0 authentication methods(https://developers.google.com/accounts/docs/OAuth2ForDevices). They are available via the #authorization_code, #implicit, #password, #client_credentials, #refresh_token
and #device methods on a client object.

The #get_token method on the grants does not make any assumptions about the format ofthe response from the OAuth provider. The ideal
case would be to treat all responses as JSON. However, some services may respond with in XML instead of JSON. The #get_token method
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

# Client Examples
This library comes bundled with two sample implementations of Google and Yammer OAuth clients. These clients are 
meant to showcase the degree of flexibilty that you get when using this library to interact with other OAuth 2.0
providers.

## Google Client

```ruby

google_client = GoogleClient.new(
  'https://accounts.google.com',
  '827502413694.apps.googleusercontent.com',
  'a2nQpcUm2Dgq1chWdAvbXGTk',
  {
    :token_path     => '/o/oauth2/token',
    :authorize_path => '/o/oauth2/auth',
    :device_path    => '/o/oauth2/device/code'
  }
)

```

### Client-side authorization URL(Implicit grant)
```ruby
auth_url = google_client.webserver_authorization_url(
    :scope => 'https://www.googleapis.com/auth/userinfo.email',
    :state => '/profile',
    :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
    :approval_prompt => 'force')
# => https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email&state=%2Fprofile&redirect_uri=https%3A%2F%2Foauth2-login-demo.appspot.com%2Ftoken&approval_prompt=force&response_type=token&client_id=812741506391.apps.googleusercontent.com
```

### Server-side authorization URL(Authorization code grant)
```ruby
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
  "access_token" : "ya91.AHES8ZS-oCZnc5yHepnsosFjNln9ZKLuioF6FcMRCGUIzA",
  "token_type" : "Bearer",
  "expires_in" : 3600,
  "id_token" : "eyJhbGciOiJSUzI1NiIsImtpZCI6IjY4ZGM2ZmIxNDQ5OGJmMWRhNjNiMWYyMDA2YmRmMDA2N2Q4MzY",
  "refresh_token" : "6/Ju8uhi9xOctGEyHRzWwHhaYimfxmY0tiJ_qW3qvjWXM"
}
```

## Copyright
Copyright (c) 2012 Kevin Mutyaba
See [LICENSE][] for details.
[license]: https://github.com/tiabas/oauth2-client/blob/master/LICENSE