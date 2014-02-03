require File.expand_path('../../../spec_helper', __FILE__)
require 'oauth2/helper'

describe OAuth2Client::Grant::Base do

  before :all do
    @client = OpenStruct.new(
      :host           => 'example.com',
      :client_id      => 's6BhdRkqt3',
      :client_secret  => 'SplxlOBeZQQYbYS6WxSbIA',
      :authorize_path => '/oauth2/authorize',
      :token_path     => '/oauth2/token',
      :device_path    => '/oauth2/device',
      :connection     => OpenStruct.new
    )
  end

  subject do
    OAuth2Client::Grant::Base.new(@client)
  end

  describe "#make_request" do
    context "without authenticate option" do
      it "does not send authorization credentials" do
        @client.connection.should_receive(:send_request).with(:get, '/oauth2', {})
        subject.make_request(:get, '/oauth2')
      end
    end

    context "with authenticate option" do
      context "option is headers" do
        it "authorization credentials in headers" do
          opts = {
            :headers => {'Authorization' => OAuth2Client::UrlHelper::http_basic_encode(@client.client_id, @client.client_secret)},
            :params  => {:client_id => @client.client_id}
          }
          @client.connection.should_receive(:send_request).with(:get, '/oauth2', opts)
          subject.make_request(:get, '/oauth2', :authenticate => :headers, :params => {:client_id => @client.client_id})
        end
      end

      context "option is body" do
        it "authorization credentials in body" do
          opts = {
            :params  => {
              :code => 'abc123',
              :client_id => @client.client_id,
              :client_secret => @client.client_secret
            },
          }
          @client.connection.should_receive(:send_request).with(:get, '/oauth2', opts)
          subject.make_request(:get, '/oauth2', :params => {:code => 'abc123'}, :authenticate => :body)
        end
      end
    end   
  end
end