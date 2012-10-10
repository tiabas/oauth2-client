class YammerOAuthClient < OAuth2Client::Client
  def normalize_scope(scope, sep=' ')
    unless (scope.is_a?(String) || scope.is_a?(Array))
      raise "Expected scope of type String or Array but was #{scope.class.name}"
    end
    return scope if scope.is_a?(String)
    scope.join(sep)
  end

  def authorization_url(params)
    raise "Response Type expected but was nil" unless params[:response_type]
    response_type = params.delete(:response_type)
    params[:scope] = normalize_scope(params[:scope]) if params[:scope]
    implicit(response_type, params).authorization_url
  end
end