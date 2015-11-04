load "ThreadPool.rb"
require 'socket'
require 'net/http'

class Server

	def initialize(port)
		@port = port
		@server = TCPServer.open(@port)
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

			if msg[0,5] == "HELO " # handle the base test
				arg = "#{msg}" + "IP:#{@ip}\n" +
				"Port:#{@port}" +
				"\nStudentID:#{student_id}"
				c.puts (arg)
				next
			end

			if msg == "KILL_SERVICE\n"	# handle the shutdown command
				c.close
				server.close
				raise SystemExit			
			end

			message = msg.split("\n")			
			# p message

			message_hash = Hash.new
			for line in message
				temp =line.split(":")
				message_hash[temp[0].chomp] = temp[1].chomp
			end

			p message_hash

			if message_hash.has_key?("JOIN_CHATROOM")

				if @chatrooms.has_key?(message_hash["JOIN_CHATROOM"])
					@chatrooms[message_hash["JOIN_CHATROOM"]]["members"] << message_hash["CLIENT_NAME"]

				else
					@chatrooms[message_hash["JOIN_CHATROOM"]] = {}
					@chatrooms[message_hash["JOIN_CHATROOM"]]["members"] = [message_hash["CLIENT_NAME"]]
					@chatrooms[message_hash["JOIN_CHATROOM"]]["ROOM_REF"] = @chatrooms.length
				end

				if !(@clients.has_key?(message_hash["CLIENT_NAME"]))
					p 'CLIENT_NAME'
					join_id = @clients.length + 1
					@clients[message_hash["CLIENT_NAME"]] = [join_id, c]
				end

				arg = "JOINED_CHATROOM:#{message_hash["JOIN_CHATROOM"]}\n" + 
					"SERVER_IP:#{@ip}\nPORT:#{@port}\n" + 
					"ROOM_REF:#{@chatrooms[message_hash["JOIN_CHATROOM"]]["ROOM_REF"]}\n" + 
					"JOIN_ID:#{@clients[message_hash["CLIENT_NAME"]][0]}\n"

				c.puts(arg)
				next

			end


		end
	end

end

port = 2000
if ARGV.length != 0 
	port = ARGV[0]
end
Server.new(port)
