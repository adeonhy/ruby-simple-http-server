require 'socket'
require './request_parser'
require './request_handler'

module SimpleServer
  class Server
    def initialize(port: DEFAULT_PORT, parser: RequestParser.new, handler: RequestHandler.new)
      @port = port
      @parser = parser
      @handler = handler
    end

    def run
      server = TCPServer.open(@port)
      puts "server is listening on #{server.addr}"

      while true
        Thread.start(server.accept) do |socket|
          puts "#{socket} is accepted."

          request = @parser.to_request(socket)
          p request
          response = @handler.to_response(request)
          socket.write(response)

          socket.close
        end
      end
    end
  end
end

DEFAULT_PORT = 8080

if __FILE__ == $0
  SimpleServer::Server.new.run
end
