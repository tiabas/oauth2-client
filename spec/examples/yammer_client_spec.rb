require File.expand_path('../../spec_helper', __FILE__)
require 'yammer_client'

describe YammerClient do

  subject do
    YammerClient.new('https://www.yammer.com', 'PRbTcg9qjgKsp4jjpm1pw', 'a2nQpcUm2Dgq1chWdAvbXGTk')
  end

  describe "#clientside_authorization_url" do
    it "returns url string for obtaining authorization" do
      params = {
        'client_id'     => 'PRbTcg9qjgKsp4jjpm1pw',
        'response_type' => 'token'
      }

      auth_url = subject.clientside_authorization_url

      parsed_url = Addressable::URI.parse(auth_url)
      expect(parsed_url.path).to eq '/dialog/oauth/authorize'
      expect(parsed_url.query_values).to eq params
      expect(parsed_url.scheme).to eq 'https'
      expect(parsed_url.host).to eq 'www.yammer.com'
    end
  end

  describe "#webserver_authorization_url" do
    it "returns the authorization url" do
      params = {
        "client_id" => "PRbTcg9qjgKsp4jjpm1pw",
        "redirect_uri" => "https://localhost/callback",
        "response_type" =>"code",
        "state" => "12345"
      }

      auth_url = subject.webserver_authorization_url(
        :client_id => 'PRbTcg9qjgKsp4jjpm1pw',
        :state => '12345',
        :redirect_uri => 'https://localhost/callback'
      )

      parsed_url = Addressable::URI.parse(auth_url)
      expect(parsed_url.path).to eq '/dialog/oauth/authorize'
      expect(parsed_url.query_values).to eq params
      expect(parsed_url.scheme).to eq 'https'
      expect(parsed_url.host).to eq 'www.yammer.com'
    end
  end

  describe "#exchange_auth_code_for_token" do
    it "makes a request to google oauth2 server" do

      stub_request(:post, "https://www.yammer.com/oauth2/token").with(
        :body => {
          :grant_type    => 'authorization_code',
          :code          => 'MmOGL795LbIZuJJVnL49Cc',
          :redirect_uri  => 'https://localhost',
          :client_id     => 'PRbTcg9qjgKsp4jjpm1pw',
          :client_secret => 'a2nQpcUm2Dgq1chWdAvbXGTk'
        },
        :headers => {
          'Accept'       => "application/json", 
          'User-Agent'   => "OAuth2 Ruby Gem #{OAuth2Client::Version}",
          'Content-Type' => "application/x-www-form-urlencoded"
        }
      )
      response = subject.exchange_auth_code_for_token(
        :params => {
          :code => 'MmOGL795LbIZuJJVnL49Cc',
          :redirect_uri => 'https://localhost'
        }
      )
    end
  end
end