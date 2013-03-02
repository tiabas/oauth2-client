require File.expand_path('../../../spec_helper', __FILE__)

describe OAuth2::Grant::AuthorizationCode do

  before :all do
    @host           = 'https://example.com'
    @client_id      = 's6BhdRkqt3'
    @client_secret  = 'SplxlOBeZQQYbYS6WxSbIA'
    @client = OAuth2::Client.new(@host, @client_id, @client_secret)
    OAuth2::Grant::AuthorizationCode.stub(:make_request)
  end

  subject do
    OAuth2::Grant::AuthorizationCode.new(@client)
  end

  describe "#authorization_params" do
    it "returns client_id and response_type" do
      expect(subject.send(:authorization_params)).to eq({ :client_id => "s6BhdRkqt3", :response_type => "code" })
    end
  end

  describe "#response_type" do
    it "returns response type" do
      expect(subject.response_type).to eq 'code'
    end
  end

  describe "#grant_type" do
    it "returns grant type" do
      expect(subject.grant_type).to eq 'authorization_code'
    end
  end

  describe "#authorization_path" do
    context "without parameters" do
      it "returns authorization path with only response_type and client_id in query string" do
        query_values = Addressable::URI.parse(subject.authorization_path).query_values
        expect(query_values).to eq({"response_type"=>"code", "client_id"=>"s6BhdRkqt3"})
      end
    end

    context "with parameters" do
      it "returns authorization path with exra parameters in query string" do
        path = subject.authorization_path({
          :scope => 'abc xyz',
          :state => 'state'
        })
        query_values = Addressable::URI.parse(path).query_values
        expect(query_values).to eq({"response_type"=>"code", "client_id"=>"s6BhdRkqt3", "scope" => "abc xyz", "state" => "state"})
      end
    end
  end

  describe "#token_path" do
    context "with parameters" do
      it "returns token path" do
        query_values = Addressable::URI.parse(subject.token_path).query_values
        expect(subject.token_path).to eq '/oauth2/token'
      end
    end

    context "without parameters" do
      it "returns token path with provided query parameters" do
        path = subject.token_path({
          :response_type => 'token',
          :state => '16WxSbIA',
          :code   => 's6BhdRkqt3'
        })
        query_values = Addressable::URI.parse(path).query_values
        expect(query_values).to eq({"response_type"=>"token", "code"=>"s6BhdRkqt3", "state" =>"16WxSbIA"})
      end
    end
  end

  describe "#fetch_authorization_url" do
    it "returns response authorization page from oauth server" do
      subject.should_receive(:make_request).with(:get, "/oauth2/authorize", {
        :params=> {:response_type=>"code", :client_id=>"s6BhdRkqt3"}
      })
      subject.fetch_authorization_url
    end
  end

  describe "#get_token" do
    it "exchanges authorization code for access token" do
      subject.should_receive(:make_request).with(:post, "/oauth2/token", {
        :params       => {:scope=>"abc xyz", :state=>"state", :code=>"G3Y6jU3a"},
        :authenticate => :headers
      })
      subject.get_token('G3Y6jU3a', :params => {:scope => 'abc xyz', :state => 'state'})
    end
  end
end