require 'webrick'
require 'stringio'

module Rack
  module Handler
    class WEBrick < WEBrick::HTTPServlet::AbstractServlet
      def initialize(server, app)
        super server
        @app = app
      end
      
      def setup_env(env)
        env.delete_if { |k, v| v.nil? }
        env.update({
          "rack.version" => "0.1",
          "rack.input" => STDOUT,
          "rack.errors" => STDERR,
          "rack.multithread" => true,
          "rack.multiprocess" => false,
          "rack.run_once" => false,
          "rack.url_scheme" => ["yes", "on", "1"].include?(ENV["HTTPS"]) ? "https" : "http"
        })
        env["HTTP_VERSION"] ||= env["SERVER_PROTOCOL"]
        env["QUERY_STRING"] ||= ""
        env["REQUEST_PATH"] ||= "/"
        env
      end
      
      def service(req, res)
        env = setup_env(req.meta_vars)
        env["rack.input"] = StringIO.new(req.body.to_s)
        
        status, headers, body = @app.call(env)
        
        res.status = status.to_i
        headers.each { |k, v|
          res[k] = v
        }
        body.each { |part|
          res.body << part
        }
      end
    end
  end
end
