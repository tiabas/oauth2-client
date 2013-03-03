class GoogleClient < OAuth2::Client
  # Generates the Google URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developers.google.com/accounts/docs/OAuth2UserAgent#formingtheurl
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
  #   :token_path     => '/o/oauth2/token',
  #   :authorize_path => '/o/oauth2/auth',
  #   :device_path    => '/o/oauth2/device/code'
  # })
  # client.clientside_authorization_url({
  #      :scope => 'https://www.googleapis.com/auth/userinfo.email',
  #      :state => '/profile',
  #      :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
  #      :approval_prompt => 'force',
  #    })
  # #=>
  def clientside_authorization_url(params={})
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    implicit.token_url(params)
  end

  # Generates the Google URL that the user will be redirected to in order to
  # authorize your application
  #
  # @see https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
  #   :token_path     => '/o/oauth2/token',
  #   :authorize_path => '/o/oauth2/auth',
  #   :device_path    => '/o/oauth2/device/code'
  # })
  # client.webserver_authorization_url({
  #      :scope => 'https://www.googleapis.com/auth/userinfo.email',
  #      :state => '/profile',
  #      :redirect_uri => 'https://oauth2-login-demo.appspot.com/code',
  #      :approval_prompt => 'force',
  #    })
  # #=>
  def webserver_authorization_url(params={})
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    authorization_code.authorization_url(params)
  end

  # Makes a request to google server that will swap your authorization code for an access
  # token
  #
  # @see https://developers.google.com/accounts/docs/OAuth2WebServer#handlingtheresponse
  #
  # @params [Hash] additional parameters to be include in URL eg. scope, state, etc
  #
  # client = GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
  #   :token_path     => '/o/oauth2/token',
  #   :authorize_path => '/o/oauth2/auth',
  #   :device_path    => '/o/oauth2/device/code'
  # })
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
    opts[:authenticate] ||= :body
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
  # client = GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
  #   :token_path     => '/o/oauth2/token',
  #   :authorize_path => '/o/oauth2/auth',
  #   :device_path    => '/o/oauth2/device/code'
  # })
  # client.refresh_access_token({
  #      :state => '/profile',
  #      :refresh_token => '2YotnFZFEjr1zCsicMWpAA'
  #    })
  # #=>
  def refresh_access_token(opts={})
    unless (opts[:params] && opts[:params][:refresh_token])
      raise ArgumentError.new("You must provide a refresh_token as a parameter")
    end
    opts[:authenticate] = :body
    token = opts[:params].delete(:refresh_token)
    refresh_token.get_token(token, opts)
  end


  # Generates the Google URL that allows a user to obtain an authorization
  # code for a given device
  #
  # @see https://developers.google.com/accounts/docs/OAuth2ForDevices
  def device_authorization_url(params={})
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    device.authorization_url(params)
  end
  
  # @see https://developers.google.com/accounts/docs/OAuth2ForDevices#obtainingacode
  #
  # @params [Hash] additional parameters to be include in URL eg. state
  #
  # client = GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
  #   :token_path     => '/o/oauth2/token',
  #   :authorize_path => '/o/oauth2/auth',
  #   :device_path    => '/o/oauth2/device/code'
  # })
  # client.device_code({
  #   :state => '/profile',
  # })
  # #=>
  def get_device_code(opts={})
    opts[:params] ||= {}
    opts[:params][:scope] = normalize_scope(opts[:params][:scope]) if opts[:params][:scope]
    device_code.get_code(opts)
  end

  # @see https://developers.google.com/accounts/docs/OAuth2ForDevices#obtainingatoken
  #
  # @params [Hash] additional parameters to be include in URL eg. state
  #
  # client = GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
  #   :token_path     => '/o/oauth2/token',
  #   :authorize_path => '/o/oauth2/auth',
  #   :device_path    => '/o/oauth2/device/code'
  # })
  # client.exchange_device_code_for_token({
  #      :state => '/profile',
  #      :code => 'G3Y6jU3a',
  #    })
  # #=>
  def exchange_device_code_for_token(opts={})
    unless (opts[:params] && opts[:params][:code])
      raise ArgumentError.new("You must include an device code as a parameter")
    end
    code = opts[:params].delete(:code)
    device_code.get_token(code, opts)
  end
end