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
  #      :redirect_uri => 'https://localhost:3000/oauth/v2/callback',
  #    })
  # #=>
  def clientside_authorization_url(params)
    implicit.token_path(params)
  end

  # Generates the Yammer URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developer.yammer.com/api/oauth2.html#server-side
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = YammerClient.new(config)
  # client.webserver_authorization_url({
  #      :redirect_uri => 'https://localhost:3000/oauth/v2/callback',
  #    })
  # #=>
  def webserver_authorization_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    authorization_code.authorization_path(params)
  end

  # Generates the Yammer URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developer.yammer.com/api/oauth2.html#server-side
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = YammerClient.new(config)
  # client.webserver_authorization_url({
  #      :client_secret => @client_secret
  #      :code => 'G3Y6jU3a',
  #      :redirect_uri => 'https://localhost:3000/oauth/v2/callback',
  #    })
  # #=>
  def webserver_token_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    params[:client_secret] = @client_secret
    authorization_code.token_path(params)
  end

  # Makes a request to Yammer server that will swap your authorization code for an access
  # token
  #
  # @see https://developer.yammer.com/api/oauth2.html#server-side
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = YammerClient.new(config)
  # client.exchange_auth_code_for_token({
  #      :redirect_uri => 'https://localhost:3000/oauth/v2/callback',
  #      :code => 'G3Y6jU3a',
  #    })
  # #=>
  def exchange_auth_code_for_token(opts={})
    opts[:params] ||= {}
    opts[:params][:redirect_uri] ||= redirect_uri
    code = opts[:params].delete(:code)
    authorization_code.get_token(code, opts)
  end
end