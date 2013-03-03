require File.expand_path('../../spec_helper', __FILE__)
require 'google_client'

describe GoogleClient do

  subject do
    GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
      :token_path     => '/o/oauth2/token',
      :authorize_path => '/o/oauth2/auth',
      :device_path    => '/o/oauth2/device/code',
      :connection_options => {
        :headers => {
          "User-Agent" => "GoOAuth2 0.1",
          "Accept"     => "application/json"
        }
      }
    })
  end
  #
  # https://developers.google.com/accounts/docs/OAuth2WebServer#formingtheurl
  describe "#webserver_authorization_url" do
    context "with scope as string" do
      it "returns the authorization url" do
        params = {
          "approval_prompt" => "force",
          "client_id" => "827502413694.apps.googleusercontent.com",
          "redirect_uri" => "https://localhost",
          "response_type" =>"code",
          "scope" => "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile",
          "state" => "/profile",
          "access_type" => "offline"
        }

        auth_url = subject.webserver_authorization_url(
          :scope => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
          :state => '/profile',
          :redirect_uri => 'https://localhost',
          :approval_prompt => 'force',
          :access_type => 'offline'
        )

        parsed_url = Addressable::URI.parse(auth_url)
        expect(parsed_url.path).to eq '/o/oauth2/auth'
        expect(parsed_url.query_values).to eq params
        expect(parsed_url.scheme).to eq 'https'
        expect(parsed_url.host).to eq 'accounts.google.com'
      end
    end

    context "with scope as array" do
      it "returns the authorization url" do
        params = {
          "approval_prompt"=>"force",
          "client_id"=>"827502413694.apps.googleusercontent.com",
          "redirect_uri"=>"https://localhost",
          "response_type"=>"code",
          "scope"=>"https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile",
          "state"=>"/profile"
        }

        auth_url = subject.webserver_authorization_url(
          :scope => [
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile'
          ],
          :state => '/profile',
          :redirect_uri => 'https://localhost',
          :approval_prompt => 'force'
        )

        parsed_url = Addressable::URI.parse(auth_url)
        expect(parsed_url.path).to eq '/o/oauth2/auth'
        expect(parsed_url.query_values).to eq params
        expect(parsed_url.scheme).to eq 'https'
        expect(parsed_url.host).to eq 'accounts.google.com'
      end
    end

    context "scope neither array or string" do
      it "raises and error" do
        expect do
          subject.webserver_authorization_url(
            :scope => {},
            :redirect_uri => 'https://oauth2-login-demo.appspot.com/code')
        end.to raise_error
      end
    end
  end

  describe "#exchange_auth_code_for_token" do
    it "makes a request to google oauth2 server" do

      stub_request(:post, "https://accounts.google.com/o/oauth2/token").with(
        :body => {
          :grant_type    => 'authorization_code',
          :code          => '4/o3xJkRT6SM_TpohrxC7T-4o3kqu6.MmOGL795LbIZuJJVnL49Cc-uiE7LeAI',
          :redirect_uri  => 'https://localhost',
          :client_id     => '827502413694.apps.googleusercontent.com',
          :client_secret => 'a2nQpcUm2Dgq1chWdAvbXGTk'
        },
        :headers => {
          'Accept'       => "application/json", 
          'User-Agent'   => "GoOAuth2 0.1",
          'Content-Type' => "application/x-www-form-urlencoded"
        }
      )
      response = subject.exchange_auth_code_for_token(
        :params => {
          :code => '4/o3xJkRT6SM_TpohrxC7T-4o3kqu6.MmOGL795LbIZuJJVnL49Cc-uiE7LeAI',
          :redirect_uri => 'https://localhost'
        }
      )
    end
  end

  describe "#client_authorization_url" do
    it "returns url string for obtaining authorization" do
      params = {
        "approval_prompt" => "force",
        "client_id" => "827502413694.apps.googleusercontent.com",
        "redirect_uri" => "https://oauth2-login-demo.appspot.com/token",
        "response_type" => "token",
        "scope" => "https://www.googleapis.com/auth/userinfo.email",
        "state" => "/profile"
      }

      auth_url = subject.clientside_authorization_url(
          :scope => 'https://www.googleapis.com/auth/userinfo.email',
          :state => '/profile',
          :redirect_uri => 'https://oauth2-login-demo.appspot.com/token',
          :approval_prompt => 'force'
      )

      parsed_url = Addressable::URI.parse(auth_url)
      expect(parsed_url.path).to eq '/o/oauth2/auth'
      expect(parsed_url.query_values).to eq params
      expect(parsed_url.scheme).to eq 'https'
      expect(parsed_url.host).to eq 'accounts.google.com'
    end
  end

  describe "#refresh_token" do
    it "makes a request to google to obtain new token" do

      stub_request(:post, "https://accounts.google.com/o/oauth2/token").with(
        :body => {
          :grant_type    => 'refresh_token',
          :refresh_token => '1/6BMfW9j53gdGImsiyUH5kU5RsR4zwI9lUVX-tqf8JXQ',
          :client_id     => '827502413694.apps.googleusercontent.com',
          :client_secret => 'a2nQpcUm2Dgq1chWdAvbXGTk'
        },
        :headers => {
          'Accept'       => 'application/json', 
          'User-Agent'   => 'GoOAuth2 0.1',
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      )
      subject.refresh_access_token(
        :params => {
          :refresh_token => '1/6BMfW9j53gdGImsiyUH5kU5RsR4zwI9lUVX-tqf8JXQ'
        }
      )
    end
  end

  describe "#get_device_code" do
    it "makes a request to google to obtain a device code" do
      stub_request(:post, "https://accounts.google.com/o/oauth2/device/code").with(
        :body => {
          :scope         => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
          :client_id     => '827502413694.apps.googleusercontent.com'
        },
        :headers => {
          'Accept'       => 'application/json', 
          'User-Agent'   => 'GoOAuth2 0.1',
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      )
      subject.get_device_code(
        :params => {
          :scope => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
        }
      )
    end
  end

  describe "#exchange_device_code_for_token" do
    it "makes request to google to obtain an access token" do
      stub_request(:post, "https://827502413694.apps.googleusercontent.com:a2nQpcUm2Dgq1chWdAvbXGTk@accounts.google.com/o/oauth2/token").with(
        :body => {
          :grant_type    => 'http://oauth.net/grant_type/device/1.0',
          :state         => '/profile',
          :code          => 'G3Y6jU3a'
        },
        :headers => {
          'Accept'       => 'application/json', 
          'User-Agent'   => 'GoOAuth2 0.1',
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      )
      subject.exchange_device_code_for_token(
        :params => {
          :state => '/profile',
          :code => 'G3Y6jU3a'
        }
      )
    end
  end
end