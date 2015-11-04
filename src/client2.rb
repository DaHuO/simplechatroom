require 'socket'
require 'thread'

host, port = "127.0.0.1", 2000

s = TCPSocket.open(host, port)
arg = "JOIN_CHATROOM: chatroom1
CLIENT_IP: 0
PORT: 0
CLIENT_NAME: client1"
puts arg
s.puts(arg)
# Thread.new{
while line = s.gets
	puts line
end
# }
# puts s
