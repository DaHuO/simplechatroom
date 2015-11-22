require 'socket'
require 'thread'

host, port = "127.0.0.1", 2000
# host, port = "134.226.56.4", 3333


s = TCPSocket.open(host, port)
arg = "JOIN_CHATROOM: chatroom1
CLIENT_IP: 0
PORT: 0
CLIENT_NAME: client1"
s.puts(arg)
# Thread.new{
i = 0
while i < 5
	line = s.gets
	puts line
	i +=1
end
# }
arg = "LEAVE_CHATROOM: 1
JOIN_ID: 1
CLIENT_NAME: client1"
s.puts(arg)
while line = s.gets
	puts line
end

# puts s
