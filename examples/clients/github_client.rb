class GithubClient < OAuth2Client::Client
  def normalize_scope(scope, sep=',')
    unless (scope.is_a?(String) || scope.is_a?(Array))
      raise "Expected scope of type String or Array but was #{scope.class.name}"
    end
    return scope if scope.is_a?(String)
    scope.join(sep)
  end

  def web_server_authorization_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    implicit.tken_path(params)
  end

  def exchange_auth_code_for_token(params)
    raise "Authorization code expected but was nil" unless params[:code]
    raise "Redirect URI expected but was nil" unless params[:redirect_uri]
    code = params.delete(:code)
    authorization_code.get_token(code, :redirect_uri => redirect_uri)
  end

  def refresh_access_token(params)
    refresh_token = params.delete(:refresh_token)
    refresh_token.get_token(refresh_token, params)
  end
end