require File.expand_path('../../test_helper', __FILE__)

class ConnectionTest < MiniTest::Unit::TestCase

  def build_mock_response(code, headers, body)
    response = mock()
    response.stubs(:code).returns(code)
    response.stubs(:header).returns(headers)
    response.stubs(:body).returns(body)
    response
  end

  def setup
    @config = mock()
    @config.stubs(:scheme).returns('https')
    @config.stubs(:host).returns('google.com')
    @config.stubs(:port).returns(443)
    @config.stubs(:max_redirects).returns(5)
    @config.stubs(:ssl).returns({})
    @http_connection = Net::HTTP.new('example.com')
    @http_client = OAuth2Client::Connection.new(@config)
    @mock_response = build_mock_response(200, {'Content-Type' => 'text/plain'}, 'success') 
  end

  def test_should_make_successfull_get_request
    path = '/oauth/authorize'
    params = {:client_id => '001337', :client_secret => 'abcxyz'}
    method = 'get'
    headers = {}
    uri = '/oauth/authorize?client_id=001337&client_secret=abcxyz'

    Net::HTTP.any_instance.expects(:get).with(uri, headers).returns(@mock_response)

    response = @http_client.send_request(path, params, method, {})

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_should_make_successfull_delete_request
    path = '/users/1'
    params = {}
    method = 'delete'
    headers = {}
    uri = '/users/1'
 
    Net::HTTP.any_instance.expects(:delete).with(uri, headers).returns(@mock_response)
   
    response = @http_client.send_request(path, params, method, {})

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_should_make_successfull_post_request
    path = '/users'
    params = {:first_name => 'john', :last_name => 'smith'}
    query  = Addressable::URI.form_encode(params)
    method = 'post'
    headers = {}
    uri = '/users'

    Net::HTTP.any_instance.expects(:post).with(uri, query, headers).returns(@mock_response)

    response = @http_client.send_request(path, params, method, {})

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_should_make_successfull_put_request
    path = '/users/1'
    params = {:first_name => 'jane', :last_name => 'doe'}
    query  = Addressable::URI.form_encode(params)
    method = 'put'
    headers = {}
    uri = '/users/1'

    Net::HTTP.any_instance.expects(:put).with(uri, query, headers).returns(@mock_response)

    response = @http_client.send_request(path, params, method, {})

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_client_should_follow_redirect
    @http_client.max_redirects = 1
    path = '/users/1'
    params = {:first_name => 'jane', :last_name => 'doe'}
    query  = Addressable::URI.form_encode(params)
    method = 'post'

    http_connection2 = Net::HTTP.new('abc.example.com')

    redirect_response1 = build_mock_response(302, {'Location' => 'http://abc.example.com/'}, '')
    redirect_response2 = build_mock_response(200, {'Content-Type' => 'text/plain'}, 'success')

    @http_connection.expects(:post).with('/users/1', query, {}).returns(redirect_response1)
    http_connection2.expects(:post).with('/', query, {}).returns(redirect_response2)
    @http_client.stubs(:http_connection).returns(@http_connection).then.returns(http_connection2)

    response = @http_client.send_request(path, params, method)

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_client_should_return_response_when_redirect_limit_is_exceeded
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

    response = @http_client.send_request(path, params, method)
    
    assert_equal 302, response.code
    assert_equal '', response.body
    assert_equal 'http://123.example.com/', response.header['Location']
  end

  # def test_connection_to_google
  #   path = '/'
  #   method = 'get'
  #   params = {}
  #   response = @http_client.send_request(path, params, method)
  #   assert 200, response.code.to_i
  # end
end
