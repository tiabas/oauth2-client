class GithubClient < OAuth2::Client
  
  #
  # @see http://developer.github.com/v3/oauth/#redirect-users-to-request-github-access
  #
  # @params [Hash] parameters to include in the URL eg. scope, state, redirect_uri
  #
  # client.webserver_authorization_url({
  #  :scope => 'user, public_repo',
  #  :state => '2sw543v74sfD',
  #  :redirect_uri => 'https://localhost/callback',
  # })
  # #=>
  def webserver_authorization_url(opts={})
    opts[:scope] = normalize_scope(opts[:scope], ',') if opts[:scope]
    authorization_code.authorization_url(opts)
  end

  #
  # @see http://developer.github.com/v3/oauth/#github-redirects-back-to-your-site
  #
  # @params [Hash] parameters to include in the URL eg. code, redirect_uri
  #
  # client.exchange_auth_code_for_token({
  #   :code => '2sw543v74sfD',
  #   :redirect_uri => 'https://localhost/callback',
  # })
  # #=>
  def exchange_auth_code_for_token(opts={})
    raise "Authorization code expected but was nil" unless opts[:params][:code]
    raise "Redirect URI expected but was nil" unless opts[:params][:redirect_uri]
    opts[:authenticate] = :body
    code = opts[:params].delete(:code)
    authorization_code.get_token(code, opts)
  end
end