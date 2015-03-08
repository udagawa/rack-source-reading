require 'test_helper'
require 'rack/handler/webrick'

Thread.abort_on_exception = true

class TestRackWEBrick < MiniTest::Test
  include Rack::TestHelpers
  
  def before_setup
    @host = '0.0.0.0' # use TestHelpers
    @port = 3000      # use TestHelpers
    @server = WEBrick::HTTPServer.new({
      BindAddress:@host,
      Port:@port,
      Logger:WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
      AccessLog:[]
    }) 
    @server.mount "/test", Rack::Handler::WEBrick, TestRequest.new
    Thread.new { @server.start }
    trap(:INT) { @server.shutdown }
  end

  def after_teardown
    @server.shutdown
  end
    
  def test_get
    GET("/test")
    assert { 200 == status }
    assert { "/" == response["REQUEST_PATH"] }
    assert { "" == response["QUERY_STRING"] }
  end

  def test_get_query
    GET("/test/foo?a=1")
    assert { 200 == status }
    assert { "/" == response["REQUEST_PATH"] }
    assert { "a=1" == response["QUERY_STRING"] }
  end

  def test_post
    POST("/test")
    assert { 200 == status }
    assert { "/" == response["REQUEST_PATH"] }
    assert { "" == response["QUERY_STRING"] }
  end

  def test_post_query
    POST("/test/foo?a=1")
    assert { 200 == status }
    assert { "/" == response["REQUEST_PATH"] }
    assert { "a=1" == response["QUERY_STRING"] }
  end

  def test_post_form_data
    POST("/test?a=1", {"rack-form-data" => "23"}, {"X-test-header" => '42'})
    assert { 200 == status }
    assert { "/" == response["REQUEST_PATH"] }
    assert { "a=1" == response["QUERY_STRING"] }
    assert { "42" == response["HTTP_X_TEST_HEADER"] }
    assert { "rack-form-data=23" == response["test.postdata"] }
  end

  def test_http_auth
    GET("/test/", {username:"ruth", password:"secret"})
    assert { "Basic cnV0aDpzZWNyZXQ=" == response["HTTP_AUTHORIZATION"] }
    POST("/test/", {}, {username:"ruth", password:"secret"})
    assert { "Basic cnV0aDpzZWNyZXQ=" == response["HTTP_AUTHORIZATION"] }
  end

  def test_secret_403
    GET("/test/?secret")
    assert { 403 == status }
    POST("/test/?secret")
    assert { 403 == status }
  end

  def set_env(key, value, &block)
    backup = ENV[key]
    begin
      ENV[key] = value
      block.call if block
    ensure
      ENV[key] = backup
    end
  end
  
  def test_url_scheme
    env = {
      ""=>"http",
      "yes"=>"https",
      "on"=>"https",
      "1"=>"https",
      "YES"=>"http",
      "true"=>"http",
    }
    env.each { |key, value|
      set_env("HTTPS", key) {
        GET("/test")
        assert { value == response["rack.url_scheme"] }
      }
    }
  end

  def test_enviroment_webrick
    GET("/test")
    assert { nil != response }
    assert { nil != response["rack.version"] }
    assert { StringIO === response["rack.input"] }
    assert { STDERR.class.name === response["rack.errors"].class.name }
    assert { true == response["rack.multithread"] }
    assert { false == response["rack.multiprocess"] }
    assert { false == response["rack.run_once"] }
    assert { "http" == response["rack.url_scheme"] }
    assert { "HTTP/1.1" == response["HTTP_VERSION"] }
    assert { "" == response["QUERY_STRING"] }
    assert { "/" == response["REQUEST_PATH"] }
  end
end
