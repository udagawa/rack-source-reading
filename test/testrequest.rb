require 'yaml'

class TestRequest
  def call(env)
    status = env["QUERY_STRING"] =~ /secret/ ? 403 : 200
    env["test.postdata"] = env["rack.input"].read
    [status, {"Content-Type" => "text/yaml" }, [env.to_yaml]]
  end
end
