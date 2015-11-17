require 'socket'
require 'thread'

host, port = "127.0.0.1", 2000

s = TCPSocket.open(host, port)
arg = "LEAVE_CHATROOM: 1
JOIN_ID: 1
CLIENT_NAME: client1"
puts arg
s.puts(arg)
# Thread.new{
while line = s.gets
	puts line
end
# }
# puts s
