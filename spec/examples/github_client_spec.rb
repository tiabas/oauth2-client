require File.expand_path('../../spec_helper', __FILE__)
require 'github_client'

describe GithubClient do

  subject do
    GithubClient.new('https://github.com', '2945e6425da3d5d17ffc', '0a8f686f2835a70a79dbcece2ec63bc5079f40a8')

    # GithubClient.new('https://github.com', '82f971d013e8d637a7e1', '1a1d59e1f8b8afa5f73e9dc9f17e25f7876e64ac')
  end

  describe "#webserver_authorization_url" do
    it "returns the authorization url" do
        auth_url = subject.webserver_authorization_url(
          :scope => 'repo, user',
          :state => '1kd84ur7q0c9rbtnd',
          :redirect_uri => 'https://localhost/callback'
        )

        parsed_url = Addressable::URI.parse(auth_url)
        expect(parsed_url.path).to eq '/login/oauth/authorize'
        expect(parsed_url.query_values).to eq({
          "client_id"     => '2945e6425da3d5d17ffc',
          "redirect_uri"  => 'https://localhost/callback',
          "response_type" => 'code',
          "scope"         => 'repo, user',
          "state"         => '1kd84ur7q0c9rbtnd'
        })
        expect(parsed_url.scheme).to eq 'https'
        expect(parsed_url.host).to eq 'github.com'
    end
  end

  describe "#exchange_auth_code_for_token" do
    it "makes a request to google oauth2 server" do

      stub_request(:post, "https://github.com/login/oauth/access_token").with(
        :body => {
          :grant_type    => 'authorization_code',
          :code          => 'IZuJJVnL49Cc',
          :redirect_uri  => 'https://localhost/callback',
          :client_id     => '2945e6425da3d5d17ffc',
          :client_secret => '0a8f686f2835a70a79dbcece2ec63bc5079f40a8'
        },
        :headers => {
          'Accept'       => "application/json", 
          'User-Agent'   => "OAuth2 Ruby Gem #{OAuth2::Version}",
          'Content-Type' => "application/x-www-form-urlencoded"
        }
      )
      response = subject.exchange_auth_code_for_token(
        :params => {
          :code => 'IZuJJVnL49Cc',
          :redirect_uri => 'https://localhost/callback'
        }
      )
    end
  end
end