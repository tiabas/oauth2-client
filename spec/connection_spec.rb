require 'spec_helper'

describe Connection do

  subject do
    @conn = OAuth2::Connection.new('http://yammer.com')
  end

  context "with user options" do
    before do
      conn = OAuth2::Connection.new('https://microsoft.com', {
        :accept => 'application/xml',
        :user_agent => "OAuth2 Test Client"
        :ssl => {:verify => false},
        :max_redirects => 2
        })
      options = OAuth2::HTTPConnection.default_options
      options.each do |key|
          expect(conn.instance_variable_get(:"@#{key}")).to eq options[key]
      end
    end
  end

  describe "#default_headers"
    it "returns user_agent and response format" do
      expect(conn.default_headers).to eq {:accept => 'application/json',
                                          :user_agent => "OAuth2 Ruby Gem #{OAuth2::Version}"
                                         }
    end
  end

  describe "#scheme" do
    it "returns the http scheme" do
      expect(conn.scheme).to eq 'http'
    end
  end
  
  describe "#host"
    it "returns the host server" do
      expect(conn.host).to eq 'yammer.com'
    end
  end

  describe "#port"
    it "returns the port" do
      expect(conn.port).to eq 80
    end
  end

  describe "#ssl?"
    it "returns a boolean based on the scheme" do
      expect(conn.ssl?).to eq false
    end
  end

  describe "#http_connection"
  end

  describe "#absolute_url"
    context "with no parameters"
      it "returns a uri without path" do
      end
    end

    context "with parameters"
      it "returns a uri with path" do
      end
    end
  end

  describe "#configure_ssl" do
  end

  describe "#ssl_verify_mode" do
    context "ssl verify not specified" do
      it "returns OpenSSL::SSL::VERIFY_PEER" do
      end
    end

    context "ssl verify specified" do
      it "returns OpenSSL::SSL::VERIFY_PEER when verify is true" do
      end

      it "returns OpenSSL::SSL::VERIFY_NONE when verify is false" do
      end
    end
  end

  describe "ssl_cert_store" do
  end 

  describe "#request" do

    it "should_make_successfull_get_request" do
      path = '/oauth/authorize'
      params = {:client_id => '001337', :client_secret => 'abcxyz'}
      method = 'get'
      headers = {}
      full_path = '/oauth/authorize?client_id=001337&client_secret=abcxyz'

      Net::HTTP.should_receive(:get).with(full_path, headers).and_return(@mock_response)
      response = @http_client.request(path, params, method, {})

      expect(response.code).to eq 200
      expect(response.body).to eq 'success'
      expect(response.header['Content-Type']).to eq 'application/json'
    end

    it "should_make_successfull_delete_request" do
      path = '/users/1'
      params = {}
      method = 'delete'
      headers = {}
   
      Net::HTTP.should_receive(:delete).with(path, headers).and_return(@mock_response)
      response = @http_client.request(path, params, method, {})

      expect(response.code).to eq 200
      expect(response.body).to eq 'success'
      expect(response.header['Content-Type']).to eq 'application/json'
    end

    it "should_make_successfull_post_request" do
      path = '/users'
      params = {:first_name => 'john', :last_name => 'smith'}
      query  = Addressable::URI.form_encode(params)
      method = 'post'
      headers = {}

      Net::HTTP.should_receive(:post).with(path, query, headers).and_return(@mock_response)
      response = @http_client.request(path, params, method, {})

      expect(response.code).to eq 200
      expect(response.body).to eq 'success'
      expect(response.header['Content-Type']).to eq 'application/json'
    end

    it "should_make_successfull_put_request" do
      path = '/users/1'
      params = {:first_name => 'jane', :last_name => 'doe'}
      query  = Addressable::URI.form_encode(params)
      method = 'put'
      headers = {}

      Net::HTTP.should_receive(:put).with(path, query, headers).and_return(@mock_response)

      response = @http_client.request(path, params, method, {})

      expect(response.code).to eq 200
      expect(response.body).to eq 'success'
      expect(response.header['Content-Type']).to eq 'application/json'
    end

    it "client_should_follow_redirect" do
      @http_client.max_redirects = 1
      path = '/users/1'
      params = {:first_name => 'jane', :last_name => 'doe'}
      query  = Addressable::URI.form_encode(params)
      method = 'post'

      http_connection2 = Net::HTTP.new('abc.example.com')

      redirect_response1 = build_mock_response(302, {'Location' => 'http://abc.example.com/'}, '')
      redirect_response2 = build_mock_response(200, {'Content-Type' => 'application/json'}, 'success')

      @http_connection.expects(:post).with('/users/1', query, {}).returns(redirect_response1)
      http_connection2.expects(:post).with('/', query, {}).returns(redirect_response2)
      @http_client.stubs(:http_connection).returns(@http_connection).then.returns(http_connection2)

      response = @http_client.request(path, params, method)

      expect(response.code).to eq 200
      expect(response.body).to eq 'success'
      expect(response.header['Content-Type']).to eq 'application/json'
    end

    it "client_should_return_response_when_redirect_limit_is_exceeded" do
      @http_client.max_redirects = 2
      path = '/users/1'
      params = {:first_name => 'jane', :last_name => 'doe'}
      query  = Addressable::URI.form_encode(params)
      method = 'post'

      http_connection2 = mock()
      http_connection3 = mock()

      redirect_response1 = build_mock_response(302, {'Location' => 'http://abc.example.com/'}, '')
      redirect_response2 = build_mock_response(302, {'Location' => 'http://xyz.example.com/'}, '')
      redirect_response3 = build_mock_response(302, {'Location' => 'http://123.example.com/'}, '')

      @http_connection.expects(:post).with('/users/1', query, {}).returns(redirect_response1)
      http_connection2.expects(:post).with('/', query, {}).returns(redirect_response2)
      http_connection3.expects(:post).with('/', query, {}).returns(redirect_response3)
      @http_client.stubs(:http_connection).returns(@http_connection).then.returns(http_connection2).then.returns(http_connection3)

      response = @http_client.request(path, params, method)
      
      assert_equal 302, response.code
      assert_equal '', response.body
      assert_equal 'http://123.example.com/', response.header['Location']
    end
  end
end