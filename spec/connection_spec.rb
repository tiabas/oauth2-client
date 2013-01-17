require 'spec_helper'
require 'ostruct'

describe OAuth2::HTTPConnection do

  subject do
    @conn = OAuth2::HTTPConnection.new('https://yammer.com')
  end

  context "with user options" do
    before do
      @conn = OAuth2::HTTPConnection.new('https://microsoft.com', {
        :accept => 'application/xml',
        :user_agent => "OAuth2 Test Client",
        :ssl => {:verify => false},
        :max_redirects => 2
        })
      options = OAuth2::HTTPConnection.default_options
      options.each do |key|
          expect(@conn.instance_variable_get(:"@#{key}")).to eq options[key]
      end
    end
  end

  describe "#default_headers" do
    it "returns user_agent and response format" do
      expect(subject.default_headers).to eq ({
        "Accept"     => "application/json", 
        "User-Agent" => "OAuth2 Ruby Gem 0.9.0"
      })
    end
  end

  describe "#scheme" do
    it "returns the http scheme" do
      expect(subject.scheme).to eq 'https'
    end
  end

  describe "#scheme" do
    context "scheme is unsupported" do
      it "raises an error" do
        expect { subject.scheme = 'ftp'}.to raise_error(OAuth2::HTTPConnection::UnsupportedSchemeError)
      end
    end

    context "scheme is http" do
      it "sets the scheme" do
        subject.scheme = 'http'
        expect(subject.scheme).to eq 'http'
      end
    end

    context "scheme is https" do
      it "sets the scheme" do
        subject.scheme = 'https'
        expect(subject.scheme).to eq 'https'
      end
    end
  end

  describe "#host" do
    it "returns the host server" do
      expect(subject.host).to eq 'yammer.com'
    end
  end

  describe "#port" do
    it "returns the port" do
      expect(subject.port).to eq 443
    end
  end

  describe "#ssl?" do
    context "scheme is https" do
      it "returns true" do
        expect(subject.ssl?('https')).to eq true
      end
    end

    context "scheme is http" do
      it "returns false" do
        expect(subject.ssl?('http')).to eq false
      end
    end
  end

  describe "#http_connection" do
    it "behaves like HTTP client" do
      expect(subject.http_connection).to respond_to(:get)
      expect(subject.http_connection).to respond_to(:post)
      expect(subject.http_connection).to respond_to(:put)
      expect(subject.http_connection).to respond_to(:delete)
    end
  end

  describe "#absolute_url" do
    context "with no parameters" do
      it "returns a uri without path" do
        expect(subject.absolute_url).to eq "https://yammer.com"
      end
    end

    context "with parameters" do
      it "returns a uri with path" do
        expect(subject.absolute_url('/oauth/v2/authorize')).to eq "https://yammer.com/oauth/v2/authorize"
      end
    end
  end

  describe "#configure_ssl" do
  end

  describe "#redirect_limit_reached?" do
  end

  describe "#ssl_verify_mode" do
    context "ssl verify set to true" do
      it "returns OpenSSL::SSL::VERIFY_PEER" do
        subject.ssl = { :verify => true }
        expect(subject.send(:ssl_verify_mode)).to eq OpenSSL::SSL::VERIFY_PEER
      end
    end

    context "ssl verify set to false" do
      it "returns OpenSSL::SSL::VERIFY_NONE" do
        subject.ssl = { :verify => false }
        expect(subject.send(:ssl_verify_mode)).to eq OpenSSL::SSL::VERIFY_NONE
      end
    end
  end

  describe "ssl_cert_store" do
  end

  describe "#request" do
    before do
      @http_ok = OpenStruct.new(
        :code    => '200',
        :body    => 'success',
        :header => {'Content-Type' => "application/json"}
      )
      @http_redirect = OpenStruct.new(
        :code    => '301',
        :body    => 'redirect',
        :header => {'Location' => "http://yammer.com/members"}
      )
    end

    context "when method is not supported" do
      it "raises an error" do
        expect {subject.request(:patch, '/')}.to raise_error(OAuth2::HTTPConnection::UnhandledHTTPMethodError)
      end
    end

    context "when method is get" do
      it "returns an http response" do
        path = '/oauth/authorize'
        params = {:client_id => '001337', :client_secret => 'abcxyz'}
        method = :get
        
        normalized_path = '/oauth/authorize?client_id=001337&client_secret=abcxyz'

        Net::HTTP.any_instance.should_receive(:get).with(normalized_path, subject.default_headers).and_return(@http_ok)
        response = subject.request(method, path, :params => params)

        expect(response.code).to eq '200'
      end
    end

    context "when method is delete" do
      it "returns an http response" do
        path = '/users/1'
        method = 'delete'

        Net::HTTP.any_instance.should_receive(:delete).with(path, subject.default_headers).and_return(@http_ok)
        response = subject.request(method, path)

        expect(response.code).to eq '200'
      end
    end

    context "when method is post" do
      it "returns an http response" do
        path = '/users'
        params = {:first_name => 'john', :last_name => 'smith'}
        query  = Addressable::URI.form_encode(params)
        headers = {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)

        Net::HTTP.any_instance.should_receive(:post).with(path, query, headers).and_return(@http_ok)
        response =subject.request(:post, path, :params => params)

        expect(response.code).to eq '200'
      end
    end

    context "when method is put" do
      it "returns an http response" do
        path = '/users/1'
        params = {:first_name => 'jane', :last_name => 'doe'}
        query  = Addressable::URI.form_encode(params)
        headers = {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)

        Net::HTTP.any_instance.should_receive(:put).with(path, query, headers).and_return(@http_ok)

        response = subject.request(:put, path, :params => params)

        expect(response.code).to eq '200'
      end
    end

    it "follows redirect" do
      path = '/users'
      params = {:first_name => 'jane', :last_name => 'doe'}
      query  = Addressable::URI.form_encode(params)
      headers = {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      client = double("client")

      subject.should_receive(:http_connection).twice.and_return(client, client)
      client.should_receive(:post).ordered.with(path, query, headers).and_return(@http_redirect)
      client.should_receive(:post).ordered.with('/members', query, headers).and_return(@http_ok)

      response = subject.request(:post, path, :params => params)

      expect(response.code).to eq '200'
    end

    it "respects the redirect limit " do
      subject.max_redirects = 1
      path = '/users'
      params = {:first_name => 'jane', :last_name => 'doe'}
      query  = Addressable::URI.form_encode(params)
      headers = {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      client = double("client")

      subject.should_receive(:http_connection).twice.and_return(client, client)
      client.should_receive(:post).ordered.with(path, query, headers).and_return(@http_redirect)
      client.should_receive(:post).ordered.with('/members', query, headers).and_return(@http_redirect)

      response = subject.request(:post, path, :params => params)

      expect(response.code).to eq '301'
    end

    it "modifies http 303 redirect from POST to GET " do
      http_303 = OpenStruct.new(
        :code    => '303',
        :body    => 'redirect',
        :header => {'Location' => "http://yammer.com/members"}
      )
      path = '/users'
      params = {:first_name => 'jane', :last_name => 'doe'}
      query  = Addressable::URI.form_encode(params)
      headers = {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      client = double("client")

      subject.should_receive(:http_connection).twice.and_return(client, client)
      client.should_receive(:post).ordered.with(path, query, headers).and_return(http_303)
      client.should_receive(:get).ordered.with('/members', subject.default_headers).and_return(@http_ok)

      response = subject.request(:post, path, :params => params)

      expect(response.code).to eq '200'
    end
  end
end