require 'socket'
require 'thread'

host, port = "127.0.0.1", 2000

s = TCPSocket.open(host, port)
while arg = gets
	puts arg
	s.puts(arg)
	Thread.new{
		while line = s.gets
			puts line
		end
	}
	puts s
end
