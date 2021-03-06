require 'pathname'
require 'time'
require './mime_detector'

module SimpleServer
  class BadRequestError < StandardError; end
  class ForbiddenError < StandardError; end
  class NotFoundError < StandardError; end

  Response = Struct.new(:status_code, :content_type, :body) do
    def header
      {
        'Date' => Time.now.httpdate,
        'Server' => "SimpleHTTPServer",
        'Content-Type' => content_type,
        'Content-Length' => body.bytesize.to_s,
        'Connection' => 'Close'
      }
    end

    def to_s
      [
        "HTTP/1.1 #{status_code}",
        *header.map {|k,v| "#{k}: #{v}"},
        "",
        body
      ].join("\r\n")
    end

    def self.from_error(error)
      response = new
      response.content_type = 'text/html'

      case error
      when BadRequestError
        response.body = File.read('public/400.html')
        response.status_code = 400
      when ForbiddenError
        response.body = File.read('public/403.html')
        response.status_code = 403
      when NotFoundError
        response.body = File.read('public/404.html')
        response.status_code = 404
      else
        response.body = File.read('public/500.html')
        response.status_code = 500
      end

      response
    end
  end
        

  class RequestHandler
    def handle(request)
      response = Response.new
      mime_detector = MimeDetector.new

      begin
        raise BadRequestError unless request.method == 'GET'

        path = server_path(request.path)

        raise NotFoundError unless path.exist?

        response.body = File.read(path)
        response.status_code = 200
        
        response.content_type = mime_detector.get_mime(path.extname)
        response

      rescue StandardError => e
        p e
        puts e.backtrace.join("\n")
        Response.from_error(e)
      end
    end

    private

    def server_path(request_path)
      req_path = Pathname.new(request_path)
      path = req_path.sub(/^\//,'public/')
      path.directory? ? path.join('index.html') : path
    end
  end
end

