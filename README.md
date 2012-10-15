# OAuth2 Client Library

A Ruby wrapper for the OAuth 2.0 specification. This is an alternative to 
https://github.com/intridea/oauth2 wrapper. It designed with the idea that not
everyone who claims to support OAuth 2.0 actually implements it according to the
standard. This version therefore, affords the developer some degree of flexibility
in generating the URLs and requests needed to authorization an OAuth 2.0 application.

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
There is also support for device authentication as described in Google's OAuth 2.0 authentication methods
(https://developers.google.com/accounts/docs/OAuth2ForDevices). They are available via the #authorization_code, 
#implicit, #password, #client_credentials, and #device methods respectively.

### Authorization Code
```ruby
auth_url = client.authorization_code.authorization_path(:redirect_uri => 'http://localhost/oauth2/cb')
# => "/oauth/authorize?response_type=code&client_id={client_id}&redirect_uri=http%3A%2F%2Flocalhost%2Foauth2%2Fcb"

token_url = client.authorization_code.token_path(:code => aXW2c6bYz, :redirect_uri => 'http://localhost/oauth2/cb')
# => "/oauth/token?redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&client_secret={client_secret}&
     grant_type=authorization_code&client_id={client_id}&code=aXW2c6bYz"
```

### Implicit Grant

    auth_url = client.implicit.authorization_path(:redirect_uri => 'http://localhost/oauth2/cb')
    # => "oauth/?redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&response_type=token&client_id={client_id}"


### Password Credentials

    token = client.password.get_token('username', 'password')


### Client Credentials

    token = client.client_credentials.get_token


### Device Code

    auth_url = client.device_code.authorization_path(:scope => 'abc xyz', :state => 'state')
    # => "/oauth/device/code?scope=abc+xyz&state=state&client_id={client_id}"


## Copyright
Copyright (c) 2012 Kevin Mutyaba
See [LICENSE][] for details.
[license]: https://github.com/tiabas/oauth2-client/blob/master/LICENSE