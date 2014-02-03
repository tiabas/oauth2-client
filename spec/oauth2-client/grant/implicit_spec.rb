require File.expand_path('../../../spec_helper', __FILE__)

describe OAuth2Client::Grant::Implicit do

  before :all do
    @host           = 'example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @client = OAuth2Client::Client.new(@host, @client_id, @client_secret)
  end

  subject do
    OAuth2Client::Grant::Implicit.new(@client)
  end

  describe "#response_type" do
    it "returns response type" do
      expect(subject.response_type).to eq 'token'
    end
  end

  describe "#token_url" do
    it "generates a token path using the given parameters" do
      path = subject.token_url(:scope => 'xyz', :state => 'abc xyz')
      query_values = Addressable::URI.parse(path).query_values
      expect(query_values).to eq({"scope"=>"xyz", "state"=>"abc xyz", "response_type"=>"token", "client_id"=>"s6BhdRkqt3"})
    end
  end

  describe "#get_token" do
    it "gets access token" do
      subject.should_receive(:make_request).with(:get, "/oauth2/token", {
        :params       => {:scope=>"xyz", :state=>"abc xyz", :response_type=>"token", :client_id=>"s6BhdRkqt3"},
        :authenticate => :headers
      })
      subject.get_token(:params => {:scope => 'xyz', :state => 'abc xyz'})
    end
  end
end