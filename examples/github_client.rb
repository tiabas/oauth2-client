class GithubClient < OAuth2Client::Client
  
  def initialize(*args)
    super
    @token_path = '/login/oauth/access_token'
    @authorize_path = '/login/oauth/authorize'
  end
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
  # client.exchange_auth_code_for_token(
  #   :params => {
  #     :code => '11a0b0b64db56c30e2ef',
  #     :redirect_uri => 'https://localhost/callback',
  #   })
  # #=>
  def exchange_auth_code_for_token(opts={})
    unless (opts[:params] && opts[:params][:code])
      raise "Authorization code expected but was nil"
    end
    opts[:authenticate] = :body
    code = opts[:params].delete(:code)
    authorization_code.get_token(code, opts)
  end
end