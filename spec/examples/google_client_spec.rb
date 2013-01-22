require File.expand_path('../../spec_helper', __FILE__)

describe GoogleClient do

  subject do

    GoogleClient.new('https://accounts.google.com', '827502413694.apps.googleusercontent.com', 'a2nQpcUm2Dgq1chWdAvbXGTk',{
      :token_path     => '/o/oauth2/token',
      :authorize_path => '/o/oauth2/auth',
      :device_path    => '/o/oauth2/device/code'
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
          "redirect_uri" => "http://localhost",
          "response_type" =>"code",
          "scope" => "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile",
          "state" => "/profile",
          "access_type" => "offline"
        }

        auth_url = subject.webserver_authorization_url(
          :scope => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile',
          :state => '/profile',
          :redirect_uri => 'http://localhost',
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
          "redirect_uri"=>"http://localhost",
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
          :redirect_uri => 'http://localhost',
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

      fake_response = double(
        :code => '200',
        :body => ''
      )

      Net::HTTP.any_instance.should_receive(:post).with(
        "/o/oauth2/token", 
        "redirect_uri=https%3A%2F%2Flocalhost&code=4%2FdbB0-UD1cvrQg2EuEFtRtHwPEmvR.IrScsjgB5M4VuJJVnL49Cc8QdUjRdAI",
        {
          "Accept"=>"application/json", 
          "User-Agent"=>"OAuth2 Ruby Gem 0.9.0",
          "Authorization"=>"Basic ODI3NTAyNDEzNjk0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tOmEyblFwY1VtMkRncTFjaFdkQXZiWEdUaw==",
          "Content-Type"=>"application/x-www-form-urlencoded"
        }
      ).and_return(fake_response)

      subject.exchange_auth_code_for_token(
        :params => {
          :code => '4/dbB0-UD1cvrQg2EuEFtRtHwPEmvR.IrScsjgB5M4VuJJVnL49Cc8QdUjRdAI',
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
      fake_response = double(
        :code => '200',
        :body => ''
      )

      Net::HTTP.any_instance.should_receive(:post).with(
        "/o/oauth2/token",
        "state=%2Fprofile&grant_type=refresh_token&refresh_token=2YotnFZFEjr1zCsicMWpAA",
        {
          "Accept" => "application/json",
          "User-Agent" => "OAuth2 Ruby Gem 0.9.0",
          "Authorization" => "Basic ODI3NTAyNDEzNjk0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tOmEyblFwY1VtMkRncTFjaFdkQXZiWEdUaw==",
          "Content-Type" => "application/x-www-form-urlencoded"
        }
      ).and_return(fake_response)

      subject.refresh_access_token(
        :params => {
          :state => '/profile',
          :refresh_token => '2YotnFZFEjr1zCsicMWpAA'
        }
      )
    end
  end

  describe "#get_device_code" do
    it "makes a request to google to obtain a device code" do
      fake_response = double(
        :code => '200',
        :body => ''
      )

      Net::HTTP.any_instance.should_receive(:post).with(
        "/o/oauth2/device/code",
        "scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile&client_id=827502413694.apps.googleusercontent.com",
        {
          "Accept"=>"application/json",
          "User-Agent"=>"OAuth2 Ruby Gem 0.9.0",
          "Content-Type"=>"application/x-www-form-urlencoded"
        }
      ).and_return(fake_response)

      subject.get_device_code(
        :params => {
          :scope => 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile'
        }
      )
    end
  end

  describe "#exchange_device_code_for_token" do
    it "makes request to google to obtain an access token" do
      fake_response = double(
        :code => '200',
        :body => ''
      )

      Net::HTTP.any_instance.should_receive(:post).with(
        "/o/oauth2/token",
        "state=%2Fprofile&code=G3Y6jU3a&grant_type=http%3A%2F%2Foauth.net%2Fgrant_type%2Fdevice%2F1.0",
        {
          "Accept"=>"application/json",
          "User-Agent" => "OAuth2 Ruby Gem 0.9.0",
          "Authorization"=>"Basic ODI3NTAyNDEzNjk0LmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tOmEyblFwY1VtMkRncTFjaFdkQXZiWEdUaw==",
          "Content-Type"=>"application/x-www-form-urlencoded"
        }
      ).and_return(fake_response)

      subject.exchange_device_code_for_token(
        :params => {
          :state => '/profile',
          :code => 'G3Y6jU3a'
        }
      )
    end
  end
end