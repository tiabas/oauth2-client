require File.expand_path('../../../spec_helper', __FILE__)

describe OAuth2Client::Grant::RefreshToken do

  before :all do
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @client = OAuth2Client::Client.new(@host, @client_id, @client_secret)
  end
  subject do
    OAuth2Client::Grant::RefreshToken.new(@client)
  end

  describe "#grant_type" do
    it "returns grant type" do
      expect(subject.grant_type).to eq 'refresh_token'
    end
  end

  describe "#get_token" do
    it "gets access token" do
      subject.should_receive(:make_request).with(:post, "/oauth2/token", {
        :params       => {:grant_type=>"refresh_token", :refresh_token=>"2YotnFZFEjr1zCsicMWpAA"},
        :authenticate => :headers
      })
      subject.get_token('2YotnFZFEjr1zCsicMWpAA')
    end
  end
end