class YammerClient < OAuth2Client::Client
  def normalize_scope(scope, sep=' ')
    unless (scope.is_a?(String) || scope.is_a?(Array))
      raise "Expected scope of type String or Array but was #{scope.class.name}"
    end
    return scope if scope.is_a?(String)
    scope.join(sep)
  end

  def client_side_authorization_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    params[:path] = '/dialog/oauth/'
    implicit.token_path(params)
  end

  def webserver_authorization_url(params)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    authorization_code.authorization_path(params)
  end
end