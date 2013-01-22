require File.expand_path('../../../spec_helper', __FILE__)

describe OAuth2::Grant::ClientCredentials do

  before :all do
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @client = OAuth2::Client.new(@host, @client_id, @client_secret)
  end

  subject do
    OAuth2::Grant::ClientCredentials.new(@client)
  end

  describe "#grant_type" do
    it "returns grant type" do
      expect(subject.grant_type).to eq 'client_credentials'
    end
  end

  describe "#get_token" do
    it "exchanges authorization code for access token" do
      subject.should_receive(:make_request).with(:post, "/oauth2/token", {:params=>{:grant_type=>"client_credentials"}, :authenticate=>:headers})
      subject.get_token
    end
  end
end