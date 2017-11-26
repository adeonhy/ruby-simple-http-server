module SimpleServer
  Request = Struct.new(:method, :path, :http_version)

  class RequestParser
    def to_request(io)
      method, path, http_version = io.gets.split(/\s/)
      Request.new(method, path, http_version)
    end
  end
end
