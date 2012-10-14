class YammerClient < OAuth2Client::Client

  # Generates the Yammer URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developer.yammer.com/api/oauth2.html#client-side
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = YammerClient.new(config)
  # client.clientside_authorization_url({
  #      :redirect_uri => 'https://localhost/oauth/cb',
  #    })
  # >> https://www.yammer.com/dialog/oauth/?client_id={client_id}&
  #    redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&response_type=token
  #
  def clientside_authorization_url(params)
    absolute_url(implicit.token_path(params))
  end

  # Generates the Yammer URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developer.yammer.com/api/oauth2.html#server-side
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # >> client = YammerClient.new(config)
  # >> client.webserver_authorization_url({
  #      :redirect_uri => 'https://localhost/oauth/cb',
  #    })
  # >> https://www.yammer.com/dialog/oauth/?client_id={client_id}&
  #    redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&response_type=code
  #
  def webserver_authorization_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    absolute_url(authorization_code.authorization_path(params))
  end

  # Generates the Yammer URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developer.yammer.com/api/oauth2.html#server-side
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # >> client = YammerClient.new(config)
  # >> client.webserver_authorization_url({
  #      :client_secret => @client_secret
  #      :code => 'G3Y6jU3a',
  #      :redirect_uri => 'https://localhost/oauth/cb',
  #    })
  # >> https://www.yammer.com/oauth2/access_token?client_id={client_id}&
  #    redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&client_secret={client_secret}&
  #    grant_type=authorization_code&code=aXW2c6bYz
  #
  def webserver_token_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    params[:client_secret] = @client_secret
    absolute_url(authorization_code.token_path(params))
  end

  # Makes a request to Yammer server that will swap your authorization code for an access
  # token
  #
  # @see https://developer.yammer.com/api/oauth2.html#server-side
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # >> client = YammerClient.new(config)
  # >> client.exchange_auth_code_for_token({
  #      :redirect_uri => 'https://localhost:3000/oauth/v2/callback',
  #      :code => 'G3Y6jU3a',
  #    })
  #
  # >> POST /oauth2/access_token HTTP/1.1
  #    Host: www.yammer.com
  #    Content-Type: application/x-www-form-urlencoded
  #
  #     client_id={client_id}&code=G3Y6jU3a&grant_type=authorization_code&
  #     redirect_uri=http%3A%2F%2Flocalhost%2Foauth%2Fcb&client_secret={client_secret}
  #
  def exchange_auth_code_for_token(opts={})
    opts[:params] ||= {}
    opts[:params][:redirect_uri] ||= redirect_uri
    code = opts[:params].delete(:code)
    authorization_code.get_token(code, opts)
  end
end