require File.expand_path('../../spec_helper', __FILE__)
require 'ostruct'

describe OAuth2::Client do

  before :all do
    @client_id= 's6BhdRkqt3'
    @client_secret = '4hJZY88TCBB9q8IpkeualA2lZsUhOSclkkSKw3RXuE'
    @host = 'example.com' 
    @client = OAuth2::Client.new(@host, @client_id, @client_secret)
  end

  subject { @client }

  context "with default options" do
    describe "#token_path" do
      it "returns " do
        expect(subject.token_path).to eq '/oauth2/token'
      end
    end

    describe "#authorize_path" do
      it "returns " do
        expect(subject.authorize_path).to eq '/oauth2/authorize'
      end
    end

    describe "#device_path" do
      it "returns " do
        expect(subject.device_path).to eq '/oauth2/device/code'
      end
    end
  end

  context "with custom options" do
    subject do
      OAuth2::Client.new(@host, @client_id, @client_secret, {
        :token_path => '/o/v2/token',
        :authorize_path => '/o/v2/authorize',
        :device_path => '/o/v2/device/code'
      })
    end

    describe "#token_path" do
      it "returns token path" do
        expect(subject.token_path).to eq '/o/v2/token'
      end
    end

    describe "#authorize_path" do
      it "returns authorize path" do
        expect(subject.authorize_path).to eq '/o/v2/authorize'
      end
    end

    describe "#device_path" do
      it "returns device path" do
        expect(subject.device_path).to eq '/o/v2/device/code'
      end
    end
  end

  describe "host" do
    it "returns host" do
      expect(subject.host).to eq 'example.com'
    end
  end

  describe "host=" do
    before do
      subject.host = 'elpmaxe.com'
    end

    it "set the connection to nil" do
      expect(subject.instance_variable_get(:'@connection')).to eq nil
    end

    it "sets new host on client" do
      expect(subject.host).to eq 'elpmaxe.com'
    end
  end

  describe "#connection_options" do
    context "with default connection options" do
      it "returns empty hash" do
        expect(subject.connection_options).to eq ({})
      end
    end

    context "with custom connection options" do
      it "returns default options" do
        subject.connection_options = { :max_redirects => 10, :use_ssl => true }
        expect(subject.connection_options).to eq ({:max_redirects => 10, :use_ssl => true})
      end
    end
  end

  describe "#implicit" do
    it "returns implicit grant object" do
    expect(@client.implicit).to be_instance_of(OAuth2::Grant::Implicit)
    end
  end

  describe "#authorization_code" do
    it "returns authorization code grant" do
    expect(@client.authorization_code).to be_instance_of(OAuth2::Grant::AuthorizationCode)
    end
  end

  describe "#refresh_token" do
    it "returns refresh token grant" do
    expect(@client.refresh_token).to be_instance_of(OAuth2::Grant::RefreshToken)
    end
  end

  describe "#client_credentials" do
    it "returns client credentials grant" do
    expect(@client.client_credentials).to be_instance_of(OAuth2::Grant::ClientCredentials)
    end
  end

  describe "#password" do
    it "returns password grant" do
      expect(@client.password).to be_instance_of(OAuth2::Grant::Password)
    end
  end

  describe "" do
    it "returns device code grant" do
      expect(@client.device_code).to be_instance_of(OAuth2::Grant::DeviceCode)
    end
  end


  describe "#implicit" do
    it "returns implicit grant object" do
      expect(subject.implicit).to be_instance_of(OAuth2::Grant::Implicit)
    end
  end

  describe "#connection" do
    context "with default connection options" do
      it "returns HttpConnection" do
        expect(subject.send(:connection)).to be_instance_of(OAuth2::HttpConnection)
      end
    end

    context "with custom connection options" do
      it "returns custom connection" do
        custom_http  = Struct.new('CustomHttpClient', :url, :connection_options)
        conn_options = { :connection_client => custom_http }
        oauth_client = OAuth2::Client.new('example.com', @client_id, @client_secret, conn_options)
        expect(oauth_client.send(:connection)).to be_instance_of custom_http
      end
    end
  end
end