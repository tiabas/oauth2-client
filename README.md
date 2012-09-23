# OAuth2
A server side Ruby wrapper for the OAuth 2.0 specification. The motivation for this wrapper is to provide some the core functionality that is
needed to handle all the authentication flows that are available described in the OAuth 2.0 specification. The wrapper defines classes for handling
client authentication requests. These classes handle all the business logic for verifying the request parameters.

## Installation
  gem install oauth2-ruby

## Resources
* [View Source on GitHub][code]
* [Report Issues on GitHub][issues]

[code]: https://github.com/tiabas/oauth2-ruby
[issues]: https://github.com/tiabas/oauth2-ruby/issues

## OAuth2::Server::Request
The request class takes care of validating the parameters that are sent to the server before anything can be done with them. Depending on the combinations of 
the parameters check are made to ensure that all required parameters for a given authentication flow exist and are properly formatted. If validation fails, an OAuth2 error is thrown.

    >> request = OAuth2::Server::Request.new({
                      :client_id => 's6BhdRkqt3',
                      :response_type => 'code',
                      :redirect_uri => 'https://client.example.com/oauth/v2/cb',
                      :state => 'xyz'
                      })
    >> request.valid?
    => true

    >> request = OAuth2::Server::Request.new({
                  :client_id => 's6BhdRkqt3',
                  :redirect_uri => 'https://client.example.com/oauth/v2/cb',
                  :state => 'xyz'
                  })
    >> request.valid?
    => OAuth2::OAuth2Error::InvalidRequest: response_type or grant_type is required

## OAuth2::Server::RequestHandler
The request handler contains the logic that is needed to verify request parameters from the client and issue an access token or authorization code depending on
the response type or grant type. This class takes two arguments, an OAuth2::Server::Request and a string representing the path to your config file that indicates the class names of your datastores. Your datastores are the classes that handle the storage and retrieval of data needed for the OAuth flow. You should create datastores for the following data access_token, client_application, authorization_code, user and define them in the config.yml as follows:

    # oauth.yml
    datastores:
      access_token: OauthAccessToken
      client_application: OauthClientApplication
      authorization_code: OauthAuthorizationCode
      user: User

Here an example of how to use the request handler:

    >> request = OAuth2::Server::Request.new({
                      :client_id => 's6BhdRkqt3',
                      :response_type => 'code',
                      :redirect_uri => 'https://client.example.com/oauth/v2/cb',
                      :state => 'xyz'
                      })
    >> handler = OAuth2::Server::RequestHandler.new(request, '/path/to/oauth.yml')

    >> handler.authorization_redirect_uri
    => "https://client.example.com/oauth/v2/cb?code=AjBfNiVZ93pxKqfJ1Q3RdKrgWHYPxYmgFTpPqPVIdbg6nPPAxMzQ1MDEzNjc1&state=xyz"

    >> handler.authorization_code_response
    => { :code=>"O0RfagVSxCn6svUlxLQvSNSpCCnImfMv2zifYDPZXO19wiPYxMzQ1MDEzNzU3", :state=>"xyz" }

    >> user = User.find_by_email('abc@xyz.com') #create the user for whom we wish get a token
    >> request_2 = OAuth2::Server::Request.new({
                      :client_id => 's6BhdRkqt3',
                      :grant_type => 'authorization_code',
                      :code => 'O0RfagVSxCn6svUlxLQvSNSpCCnImfMv2zifYDPZXO19wiPYxMzQ1MDEzNzU3',
                      :redirect_uri => 'https://client.example.com/oauth/v2/cb',
                      :state => 'xyz'
                      })

    >> handler_2 = OAuth2::Server::RequestHandler.new(request_2, '/path/to/oauth.yml')

      # let's try to get the authorization code again
    >> handler_2.authorization_redirect_uri
      # we get an error
    => OAuth2::OAuth2Error::UnsupportedResponseType: unsupported response_typev

    >> handler_2.access_token_redirect_uri(user)v
    => "https://client.example.com/oauth/v2/cb#access_token=YZsr0dfkzcygr2q3rxB6g9cJdqcF7M5PjankAFG8QKz695mUT8xMzQ1MDE0MDk3&token_type=Bearer&expires_in=3600&refresh_token=j2zmwCR7BbGDjP4DySRK1J2nw8O1V4aQXY3wre6ohQNNNeOwNtgxMzQ1MDE0MDk3&state=xyz"

    >> handler_2.access_token_response(user)
    => { :access_token=>"PZGRzqCZhuc4dGsBNO6hEkHCNFvx2HfqrIgcGJifHilPDQGpNwxMzQ1MDE0NDQ2", :token_type=>"Bearer", :expires_in=>3600, :refresh_token=>"QUpDsfIg2mCTe5taePulQyfJi8QLk3rdUBEGPrpqGPKSfKocUxMzQ1MDE0NDQ2", :state=>"xyz" }

## OAuth2::Error
Whenever an OAuth operation fails an error of this type will be thrown. This class provided a convenience method to turn the error into an http response when
provided with an OAuth2::Server::Request object

    >> e = OAuth2::OAuth2Error::AccessDenied.new "the user denied your request"
    >> e.to_hsh
    => {:error=>"access_denied", :error_description=>"the user denied your request"}

    >> request = OAuth2::Server::Request.new({
                      :client_id => 's6BhdRkqt3',
                      :response_type => 'code',
                      :redirect_uri => 'https://client.example.com/oauth/v2/cb',
                      :state => 'xyz'
                      })
    >> e.redirect_uri(request)
    => "https://client.example.com/oauth/v2/cb?error=access_denied&error_description=the%20user%20denied%20your%20request"

## Supported Ruby Versions
This library aims to support and is tested against] the following Ruby
implementations:

* Ruby 1.9.2
* Ruby 1.9.3

## Copyright
Copyright (c) 2012 Kevin Mutyaba
See [LICENSE][] for details.
[license]: https://github.com/tiabas/oauth2-ruby/blob/master/LICENSE
