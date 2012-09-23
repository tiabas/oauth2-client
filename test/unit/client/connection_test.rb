class ConnectionTest < MiniTest::Unit::TestCase

  def build_mock_response(code, headers, body)
    response = mock()
    response.stubs(:code).returns(code)
    response.stubs(:header).returns(headers)
    response.stubs(:body).returns(body)
    response
  end

  def setup
    @http_connection = mock()
    @user_agent = OAuth2::Client::Connection.new('https', 'example.com')
    @mock_response = build_mock_response(200, {'Content-Type' => 'text/plain'}, 'success') 
  end

  def test_should_make_successfull_get_request
    path = '/oauth/authorize'
    params = {:client_id => '001337', :client_secret => 'abcxyz'}
    method = 'get'
    headers = {}
    uri = '/oauth/authorize?client_id=001337&client_secret=abcxyz'

    @user_agent.stubs(:http_connection).returns(@http_connection)
    @http_connection.expects(:get).with(uri, headers).returns(@mock_response)

    response = @user_agent.send_request(path, params, method, {})

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
 
    @user_agent.stubs(:http_connection).returns(@http_connection)
    @http_connection.expects(:delete).with(uri, params, headers).returns(@mock_response)
   
    response = @user_agent.send_request(path, params, method, {})

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_should_make_successfull_post_request
    path = '/users'
    params = {:first_name => 'john', :last_name => 'smith'}
    method = 'post'
    headers = {}
    uri = '/users'

    @user_agent.stubs(:http_connection).returns(@http_connection)
    @http_connection.expects(:post).with(uri, params, headers).returns(@mock_response)

    response = @user_agent.send_request(path, params, method, {})

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_should_make_successfull_put_request
    path = '/users/1'
    params = {:first_name => 'jane', :last_name => 'doe'}
    method = 'put'
    headers = {}
    uri = '/users/1'

    @user_agent.stubs(:http_connection).returns(@http_connection)
    @http_connection.expects(:put).with(uri, params, headers).returns(@mock_response)

    response = @user_agent.send_request(path, params, method, {})

    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_client_should_follow_redirect
    @user_agent.max_redirects = 1
    path = '/users/1'
    params = {:first_name => 'jane', :last_name => 'doe'}
    method = 'post'
    headers = {}
    http_connection2 = mock()

    redirect_response1 = build_mock_response(302, {'Location' => 'http://abc.example.com/'}, '')
    redirect_response2 = build_mock_response(200, {'Content-Type' => 'text/plain'}, 'success')

    @http_connection.expects(:post).with('/users/1', params, {}).returns(redirect_response1)
    http_connection2.expects(:post).with('/', params, {}).returns(redirect_response2)
    @user_agent.stubs(:http_connection).returns(@http_connection).then.returns(http_connection2)

    response = @user_agent.send_request(path, params, method, headers)

    assert_equal 'abc.example.com', @user_agent.host
    assert_equal 200, response.code
    assert_equal 'success', response.body
    assert_equal 'text/plain', response.header['Content-Type']
  end

  def test_client_should_return_response_when_redirect_limit_is_exceeded
    @user_agent.max_redirects = 2
    path = '/users/1'
    params = {:first_name => 'jane', :last_name => 'doe'}
    method = 'post'
    headers = {}
    http_connection2 = mock()
    http_connection3 = mock()
    redirect_response1 = build_mock_response(302, {'Location' => 'http://abc.example.com/'}, '')
    redirect_response2 = build_mock_response(302, {'Location' => 'http://xyz.example.com/'}, '')
    redirect_response3 = build_mock_response(302, {'Location' => 'http://123.example.com/'}, '')

    @http_connection.expects(:post).with('/users/1', params, {}).returns(redirect_response1)
    http_connection2.expects(:post).with('/', params, {}).returns(redirect_response2)
    http_connection3.expects(:post).with('/', params, {}).returns(redirect_response3)
    @user_agent.stubs(:http_connection).returns(@http_connection).then.returns(http_connection2).then.returns(http_connection3)

    response = @user_agent.send_request(path, params, method, headers)
    
    assert_equal 'xyz.example.com', @user_agent.host
    assert_equal 302, response.code
    assert_equal '', response.body
    assert_equal 'http://123.example.com/', response.header['Location']
  end
end
