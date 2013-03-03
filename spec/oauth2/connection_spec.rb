require File.expand_path('../../spec_helper', __FILE__)
require 'ostruct'

describe OAuth2::HttpConnection do

  subject do
    @conn = OAuth2::HttpConnection.new('https://example.com')
  end

  context "with user specified options" do
    before do
      @conn_opts = {
        :headers => {
          :accept     => 'application/json',
          :user_agent => 'OAuth2 Test Client'
        },
        :ssl => {:verify => false},
        :max_redirects => 2
      }
      @conn = OAuth2::HttpConnection.new('https://example.com', @conn_opts)
    end

    describe "connection options" do
      it "sets user options" do
        OAuth2::HttpConnection.default_options.keys.each do |key|
          expect(@conn.instance_variable_get(:"@#{key}")).to eq @conn_opts[key]
        end
      end
    end
  end

  describe "#default_headers" do
    it "returns user_agent and response format" do
      expect(subject.default_headers).to eq ({
        "Accept"     => "application/json", 
        "User-Agent" => "OAuth2 Ruby Gem #{OAuth2::Version}"
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
        expect { subject.scheme = 'ftp'}.to raise_error(OAuth2::HttpConnection::UnsupportedSchemeError)
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
      expect(subject.host).to eq 'example.com'
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
        subject.scheme = 'https'
        expect(subject.ssl?).to eq true
      end
    end

    context "scheme is http" do
      it "returns false" do
        subject.scheme = 'http'
        expect(subject.ssl?).to eq false
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
        expect(subject.absolute_url).to eq "https://example.com"
      end
    end

    context "with parameters" do
      it "returns a uri with path" do
        expect(subject.absolute_url('/oauth/v2/authorize')).to eq "https://example.com/oauth/v2/authorize"
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

  describe "#send_request" do
    before do
      @http_ok = OpenStruct.new(
        :code    => '200',
        :body    => 'success',
        :header => {'Content-Type' => "application/json"}
      )
      @http_redirect = OpenStruct.new(
        :code    => '301',
        :body    => 'redirect',
        :header => {'Location' => "http://example.com/members"}
      )
    end

    context "when method is not supported" do
      it "raises an error" do
        expect {subject.send_request(:patch, '/')}.to raise_error(OAuth2::HttpConnection::UnhandledHTTPMethodError)
      end
    end

    context "when method is get" do
      it "returns an http response" do
        params = {:client_id => '001337', :client_secret => 'abcxyz'}
        
        stub_get('/oauth/authorize').with(
          :query =>  params,
          :header => { 
            'Accept'          => 'application/json',
            'User-Agent'      => "OAuth2 Ruby Gem #{OAuth2::Version}",
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
          }
        )
        response = subject.send_request(:get, '/oauth/authorize', :params => params)
        expect(response.code).to eq '200'
      end
    end

    context "when method is delete" do
      it "returns an http response" do
        stub_delete('/users/1').with(
          :header => { 
            'Accept'          => 'application/json',
            'User-Agent'      => "OAuth2 Ruby Gem #{OAuth2::Version}",
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3'
          }
        )
        response = subject.send_request(:delete, '/users/1')
        expect(response.code).to eq '200'
      end
    end

    context "when method is post" do
      it "returns an http response" do
        params = {:first_name => 'john', :last_name => 'smith'}
        stub_post('/users').with(
          :body   => params,
          :header => { 
            'Accept'          => 'application/json',
            'User-Agent'      => "OAuth2 Ruby Gem #{OAuth2::Version}",
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type'    => 'application/x-www-form-urlencoded'
          }
        )
        response =subject.send_request(:post, '/users', :params => params)
        expect(response.code).to eq '200'
      end
    end

    context "when method is put" do
      it "returns an http response" do
        params = {:first_name => 'jane', :last_name => 'doe'}

        stub_put('/users/1').with(
          :body   => params,
          :header => { 
            'Accept'          => 'application/json',
            'User-Agent'      => "OAuth2 Ruby Gem #{OAuth2::Version}",
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type'    => 'application/x-www-form-urlencoded'
          }
        )
        response = subject.send_request(:put, '/users/1', :params => params)

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

      response = subject.send_request(:post, path, :params => params)

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

      response = subject.send_request(:post, path, :params => params)

      expect(response.code).to eq '301'
    end

    it "modifies http 303 redirect from POST to GET " do
      http_303 = OpenStruct.new(
        :code    => '303',
        :body    => 'redirect',
        :header => {'Location' => "http://example.com/members"}
      )
      path = '/users'
      params = {:first_name => 'jane', :last_name => 'doe'}
      query  = Addressable::URI.form_encode(params)
      headers = {'Content-Type' => 'application/x-www-form-urlencoded' }.merge(subject.default_headers)
      client = double("client")

      subject.should_receive(:http_connection).twice.and_return(client, client)
      client.should_receive(:post).ordered.with(path, query, headers).and_return(http_303)
      client.should_receive(:get).ordered.with('/members', subject.default_headers).and_return(@http_ok)

      response = subject.send_request(:post, path, :params => params)

      expect(response.code).to eq '200'
    end
  end
end