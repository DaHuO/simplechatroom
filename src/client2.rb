require 'socket'
require 'thread'

host, port = "127.0.0.1", 2000

s = TCPSocket.open(host, port)
arg = "JOIN_CHATROOM: [chatroom namei]
CLIENT_IP: [IP Address of client if UDP | 0 if TCP]
PORT: [port number of client if UDP | 0 if TCP]
CLIENT_NAME: [string Handle to identifier client user]"
puts arg
s.puts(arg)
# Thread.new{
while line = s.gets
	puts line
end
# }
# puts s
