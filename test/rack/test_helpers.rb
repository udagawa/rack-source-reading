require 'net/http'

module Rack
  module TestHelpers
    attr_reader :status, :response
   
    def GET(path, header={})
      Net::HTTP.start(@host, @port) { |http|
        username = header.delete(:username)
        password = header.delete(:password)
        
        request = Net::HTTP::Get.new(path, header)
        request.basic_auth username, password if username && password
        
        http.request(request) { |response|
          @status = response.code.to_i
          @response = YAML.load(response.body)
        }
      }
    end

    def POST(path, form_data={}, header={})
      Net::HTTP.start(@host, @port) { |http|
        username = header.delete(:username)
        password = header.delete(:password)
       
        request = Net::HTTP::Post.new(path, header)
        request.basic_auth username, password if username && password
        request.form_data = form_data
       
        http.request(request) { |response|
          @status = response.code.to_i
          @response = YAML.load(response.body)
        }
      }
    end
  end
end