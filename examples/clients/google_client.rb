class GoogleClient < OAuth2Client::Client

  def normalize_scope(scope, sep=' ')
    unless (scope.is_a?(String) || scope.is_a?(Array))
      raise ArgumentError.new("Expected scope of type String or Array but was: #{scope.class.name}")
    end
    return scope if scope.is_a?(String)
    scope.join(sep)
  end

  # Generates the Google URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developers.google.com/accounts/docs/OAuth2UserAgent#formingtheurl
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = GoogleClient.new(config)
  # client.clientside_authorization_url({
  #      :scope => 'https://www.googleapis.com/auth/userinfo.email',
  #      :state => '/profile',
  #      :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
  #      :approval_prompt => 'force',
  #    })
  # #=>
  def clientside_authorization_url(params={})
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    absolute_url(implicit.token_path(params))
  end

  # Generates the Google URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = GoogleClient.new(config)
  # client.webserver_authorization_url({
  #      :scope => 'https://www.googleapis.com/auth/userinfo.email',
  #      :state => '/profile',
  #      :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
  #      :approval_prompt => 'force',
  #    })
  # #=>
  def webserver_authorization_url(params={})
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    absolute_url(authorization_code.authorization_path(params))
  end

  # Generates the Google URL that allows a user to obtain an authorization
  # code for a given device
  #
  # @see https://developers.google.com/accounts/docs/OAuth2ForDevices
  def device_authorization_url(params={})
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    absolute_url(device.authorization_path(params))
  end

  # Makes a request to google server that will swap your authorization code for an access
  # token
  #
  # @see https://developers.google.com/accounts/docs/OAuth2WebServer#handlingtheresponse
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = GoogleClient.new(config)
  # client.exchange_auth_code_for_token({
  #      :scope => 'https://www.googleapis.com/auth/userinfo.email',
  #      :state => '/profile',
  #      :code => 'G3Y6jU3a',
  #    })
  # #=>
  def exchange_auth_code_for_token(opts={})
    unless (opts[:params] && opts[:params][:code])
      raise ArgumentError.new("You must include an authorization code as a parameter")
    end
    code = opts[:params].delete(:code)
    authorization_code.get_token(code, opts)
  end

  # Makes a request to google server that will generate a new access token given that your
  # application was not deauthorized by the user
  #
  # @see https://developers.google.com/accounts/docs/OAuth2InstalledApp#refresh
  #
  # @params [Hash] additional parameters to be include in URL eg. state
  #
  # client = GoogleClient.new(config)
  # client.refresh({
  #      :state => '/profile',
  #      :refresh_token => '2YotnFZFEjr1zCsicMWpAA'
  #    })
  # #=>
  def refresh_access_token(opts={})
    unless (opts[:params] && opts[:params][:refresh_token])
      raise ArgumentError.new("You must provide a refresh_token as a parameter")
    end
    token = opts[:params].delete(:refresh_token)
    refresh_token.get_token(token, opts)
  end

  # @see https://developers.google.com/accounts/docs/OAuth2ForDevices
  def exchange_device_code_for_token(opts={})
    opts[:params] ||= {}
    opts[:params][:scope] = normalize_scope(opts[:params][:scope]) if opts[:params][:scope]
    device.get_token(opts)
  end
end