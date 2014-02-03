require File.expand_path('../../../spec_helper', __FILE__)

describe OAuth2Client::Grant::Password do

  before :all do
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @client = OAuth2Client::Client.new(@host, @client_id, @client_secret)
  end

  subject do
    OAuth2Client::Grant::Password.new(@client)
  end

  describe "#grant_type" do
    it "returns grant type" do
      expect(subject.grant_type).to eq 'password'
    end
  end

  describe "#get_token" do
    it "gets access token" do
      subject.should_receive(:make_request).with(:post, "/oauth2/token", {
        :params => {:grant_type=>"password", :username=>"benutzername", :password=>"passwort"},
        :authenticate=>:headers
      })
      subject.get_token('benutzername', 'passwort')
    end
  end
end