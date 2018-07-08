require "socket"
require "json"
require "file_utils"

module JSONSocket
  struct Client

    def initialize(host = "localhost", port = 1234, delimeter = "#", unix_socket : String? = nil)
      @host = host
      @port = port
      @unix_socket = unix_socket
      @delimeter = delimeter
    end

    def send(object)
      begin
        if @unix_socket
          UNIXSocket.open(@unix_socket.as(String)) do |socket|
            handle_send_receive(socket, object)
          end
        else
          TCPSocket.open(@host, @port) do |socket|
            handle_send_receive(socket, object)
          end
        end
      rescue ex
        puts ex.message
      end
    end

    def handle_send_receive(socket, object)
      stringified = object.to_json
      socket << "#{stringified.size}#{@delimeter}#{stringified}\n"
      response = socket.gets
      unless response.nil?
        parts = response.split(@delimeter)
        return JSON.parse(parts[1])
      else
        raise "failed while receiving response!"
      end
    end
  end

  struct Server

    def initialize(host : String = "localhost", port : Int32 = 1234, delimeter : String = "#", unix_socket = nil)
      @delimeter = delimeter
      @server = if unix_socket
                  FileUtils.rm(unix_socket.as(String)) if File.exists?(unix_socket.as(String))
                  UNIXServer.new(unix_socket)
                else
                  TCPServer.new(host, port)
                end
      @stop = false
      @buffer = String.new
    end

    def send_end_message(socket, message)
      string = message.to_json
      socket.puts "#{string.size}#{@delimeter}#{string}\n"
      socket.close_write
    end

    def stop
      @stop = true
    end

    def listen
      loop do
        break if @stop
        @server.accept? do |socket|
          if socket
            tmp = socket.gets
            if tmp
              while !tmp.index(@delimeter).nil?
                delimeter_index = tmp.index(@delimeter)
                if delimeter_index
                  length = tmp[0..(delimeter_index - 1)].to_i
                  range = (delimeter_index + 1)..(delimeter_index + length)
                  message = tmp[range]
                  tmp = ""
                  yield JSON.parse(message), socket
                end
              end
            end
          end
        end
      end
    end

  end

end
