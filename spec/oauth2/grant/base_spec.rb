require File.expand_path('../../../spec_helper', __FILE__)

describe OAuth2::Grant::Base do

  before :all do
    @connection = double('HTTP Connection')
    @client = double(
      :host           => 'example.com',
      :client_id      => 's6BhdRkqt3',
      :client_secret  => 'SplxlOBeZQQYbYS6WxSbIA',
      :authorize_path => '/oauth2/authorize',
      :token_path     => '/oauth2/token',
      :device_path    => '/oauth2/device',
      :connection     => @connection
    )
  end

  subject do
    OAuth2::Grant::Base.new(@client)
  end

  describe "#make_request" do
    context "without authenticate option" do
      it "does not send authorization credentials" do
        @connection.should_receive(:send_request).with(:get, '/oauth2')
        subject.make_request(:get, '/oauth2')
      end
    end
  end
end