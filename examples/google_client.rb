class GoogleClient < OAuth2::Client::Client
  def normalize_scope(scope, sep=' ')
    unless (scope.is_a?(String) || scope.is_a?(Array))
      raise "Expected scope of type String or Array but was #{scope.class.name}"
    end
    return scope if scope.is_a?(String)
    scope.join(sep)
  end


  def client_side_authorization_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    implicit(response_type, params).authorization_url
  end

  def web_server_authorization_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    auth_code(response_type, params).authorization_url
  end

  def web_server_get_token(params)
    code = params.delete(:code)
    authorization_code(code, :redirect_uri => redirect_uri).get_token
  end

  def refresh_access_token(refresh_token)
    refresh_token(refresh_token).get_token
  end

  def device_code(params)
    params[:scope]  = normalize_scope(params[:scope]) if params[:scope]
    params[:path]   = params[:path] || '/o/oauth2/device/code'
    params[:method] = 'post'
    implicit(response_type, params).authorization_url
  end
end