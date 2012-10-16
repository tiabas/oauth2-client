# OAuth2 Client

A Ruby wrapper for the OAuth 2.0 specification. It is designed with the idea that not
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

@client  = Client.new(:filename => client_config_file, :service => :yammer, :env => :test)

client.authorization_code.authorization_path(:redirect_uri => 'http://localhost/oauth2/cb')
# => "/oauth/authorize?response_type=code&client_id={client_id}&redirect_uri=http%3A%2F%2Flocalhost%2Foauth2%2Fcb"

```

## Authorization Grants
The client wraps around the creation of any given grant and passing in the parameters defined in the configuration
file. The supported grants include Authorization Code, Implicit, Resource Owner Password Credentials, Client Credentials.
There is also support for device authentication as described in Google's OAuth 2.0 authentication methods(https://developers.google.com/accounts/docs/OAuth2ForDevices). They are available via the #authorization_code, #implicit, #password, #client_credentials, #refresh_token
and #device methods on a client object.

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

## Configuration
The client settings are loaded from a configuration file.

```yaml
#oauth_client.yml

test:
  google:
    client_id: '812741506391.apps.googleusercontent.com'
    client_secret: 'SplxlOBeZQQYbYS6WxSbIA'
    scheme: https
    host: accounts.google.com
    port: 443
    token_path: /o/oauth2/token
    authorize_path: /o/oauth2/auth
    device_path: /o/oauth2/device/code
    http_client: 
    max_redirects: 5
    ssl:

  yammer:
    client_id: 'PRbTcg9qjgKsp4jjpm1pw'
    client_secret: 'Xn7kp7Ly0TCY4GtZWkmSsqGEPg10DmMADyjWkf2U'
    scheme: https
    host: www.yammer.com
    port: 443
    token_path: /oauth2/access_token
    authorize_path: /dialog/oauth/
    device_path:
    http_client: 
    max_redirects: 5
    ssl: 
```

## Yammer Client

```ruby
yammer_client  = YammerClient.new(:filename => client_config_file, :service => :yammer, :env => :test)
```

### Client-side authorization URL(Implicit grant)
```ruby
auth_url = yammer_client.webserver_authorization_url(:redirect_uri =>"http://localhost/oauth/cb")
# => https://www.yammer.com/dialog/oauth/?redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&response_type=token&client_id=PQbTcg6qjgKpp4jjpm4pw
```

### Server-side authorization URL(Authorization code grant)
```ruby

auth_url = yammer_client.clientside_authorization_url(:redirect_uri =>"http://localhost/oauth/cb")
# => https://www.yammer.com/dialog/oauth/?redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&response_type=code&client_id=PQbTcg6qjgKpp4jjpm4pw

# exchange authorization code for access token
token_url = yammer_client.webserver_token_url(:code => 'aXW2c6bYz', :redirect_uri =>"http://localhost/oauth/cb")
# => https://www.yammer.com/oauth2/access_token?code=aXW2c6bYz&redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&client_secret=Xn4kp7Ly0TCY4GaZWkmSsqIEPg10DmMADyjWkf2U&grant_type=authorization_code&client_id=PQbTcg6qjgKpp4jjpm4pw

```

## Google Client

```ruby
google_client = GoogleClient.new(:filename => client_config_file, :service => :google, :env => :test)
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

# exchange authorization code for access token
response = google_client.exchange_auth_code_for_token(
  :params => {
    :code => '4/dbB0-UD1cvrQg2EuEFtRtHwPEmvR.IrScsjgB5M4VuJJVnL49Cc8QdUjRdAI',
    :redirect_uri => 'http://localhost/oauth/token'
  }
)
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