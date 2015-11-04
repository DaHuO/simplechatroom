load "ThreadPool.rb"
require 'socket'
require 'net/http'

class Server

	def initialize(port)
		@server = TCPServer.open(port)
		@chatrooms = Hash.new
		@clients = Hash.new
		uri = URI('http://ipecho.net/plain')
		body = Net::HTTP.get(uri)
		if body.length!=0
			@ip = body
		else
			@ip = '127.0.0.1'
		end
		run
	end

	def run
		p "ruing"
		count = 0
		thread_pool = ThreadPool.new(5)
		loop{
			client = @server.accept
			thread_pool.schedule(client) do |c|
				p "into thread pool"
				count += 1
				handle_client(c, count, @server)
				p "hi there"
			end
		}


	end

	def handle_client(c, count, server)
		p "handle_client"
		student_id = 'oldk'

		while input = c.recvmsg
			p c.remote_address.ip_address
			msg = input[0]
			p input

			if input[0,5] == "HELO " # handle the base test
				arg = "#{input}" + "IP:#{$ip}\n" +
				"Port:#{$port}" +
				"\nStudentID:#{student_id}"
				c.puts (arg)
			end

			if input == "KILL_SERVICE\n"	# handle the shutdown command
				c.close
				server.close
				raise SystemExit			
			end

			message = input.split("\n")
			p message

		end
	end

end

port = 2000
if ARGV.length != 0 
	port = ARGV[0]
end
Server.new(2000)
