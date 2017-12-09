module SimpleServer
  Request = Struct.new(:method, :path, :http_version)

  class RequestParser
    def parse(io)
      method, path, http_version = io.gets.split(/\s/)
      Request.new(method, path, http_version)
    end
  end
end
