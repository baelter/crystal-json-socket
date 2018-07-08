# crystal json-socket [![Build Status](https://travis-ci.org/foi/crystal-json-socket.svg?branch=master)](https://travis-ci.org/foi/crystal-json-socket)

JSON-socket client & server implementation. Inspired by and wish for compatibility with  [sebastianseilund/node-json-socket](https://github.com/sebastianseilund/node-json-socket/)

## Installation

Add this to your application's `shard.yml`:
```
dependencies:
  json-socket:
    github: foi/crystal-json-socket
```

## Usage

server.cr

```
require "json-socket"

struct CustomJSONSocketServer

  include JSONSocket::Server

  def on_message(message, socket)
    puts message
    result = (message["a"].as_i + message["b"].as_i) * message["b"].as_i * message["a"].as_i
    self.send_end_message(socket, { :result => result})
  end

end

server = CustomJSONSocketServer.new("127.0.0.1", 1234) # OR CustomJSONSocketServer.new(unix_socket: "/tmp/json-socket-server.sock", delimeter: "µ")
server.listen
```

client.cr

```
require "json-socket"
to_server = JSONSocket::Client.new(host: "127.0.0.1", port: 1234) # OR JSONSocket::Client.new(unix_socket: "/tmp/json-socket-server.sock", delimeter: "µ")
result = to_server.send({ a: 12, b: 8})
if (result)
  puts result
end
```

#### NOTE: node-json-socket support in limited because crystal's socket.gets is not receiving messaged without \n at the end. For activating this limited support you need set node_json_socket_compatibility: true when creating server (.new)
