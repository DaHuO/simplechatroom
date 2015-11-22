load "ThreadPool.rb"
require 'socket'
require 'net/http'

class Server

	def initialize(port)
		@port = port
		@server = TCPServer.open(@port)
		@chatrooms = Hash.new
		@clients = Hash.new
		@chatroom_ref = 0
		@join_id = 0
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
		p 'hi there'
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

		# while input = c.recv(1000)
		while input = c.recvmsg

			msg = input[0]
			if msg.length !=0
				puts "incoming msg is #{msg}"
			end
			# msg = input

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

			message_hash = Hash.new
			for line in message
				temp =line.split(":")
				message_hash[temp[0].strip] = temp[1].strip
			end

			if message_hash.has_key?("JOIN_CHATROOM")
				p "JOIN_CHATROOM"

				if !(@clients.has_key?(message_hash["CLIENT_NAME"]))
					p 'CLIENT_NAME'
					@join_id += 1
					join_id = @join_id
					@clients[message_hash["CLIENT_NAME"]] = [join_id, c]
				end

				if @chatrooms.has_key?(message_hash["JOIN_CHATROOM"])
					@chatrooms[message_hash["JOIN_CHATROOM"]]["MEMBERS"] << message_hash["CLIENT_NAME"]

				else
					@chatroom_ref += 1
					@chatrooms[message_hash["JOIN_CHATROOM"]] = Hash.new
					@chatrooms[message_hash["JOIN_CHATROOM"]]["MEMBERS"] = []
					@chatrooms[message_hash["JOIN_CHATROOM"]]["MEMBERS"] << message_hash["CLIENT_NAME"]
					@chatrooms[message_hash["JOIN_CHATROOM"]]["ROOM_REF"] = @chatroom_ref
				end
			
				arg = "JOINED_CHATROOM:#{message_hash["JOIN_CHATROOM"]}\n" + 
					"SERVER_IP:#{@ip}\nPORT:#{@port}\n" + 
					"ROOM_REF:#{@chatrooms[message_hash["JOIN_CHATROOM"]]["ROOM_REF"]}\n" + 
					"JOIN_ID:#{@clients[message_hash["CLIENT_NAME"]][0]}\n"

				c.puts(arg)

				arg2 = "CHAT:#{@chatrooms[message_hash["JOIN_CHATROOM"]]["ROOM_REF"]}\n" + 
					"CLIENT_NAME:#{message_hash["CLIENT_NAME"]}\n" + 
					"MESSAGE:#{message_hash["CLIENT_NAME"]} has joined this chatroom.\n\n"

				for member in @chatrooms[message_hash["JOIN_CHATROOM"]]["MEMBERS"]
					@clients[member][1].puts(arg2)
				end

				next

			end

			if message_hash.has_key?("LEAVE_CHATROOM")

				p "LEAVE_CHATROOM"
				chatroom_name =""

				for chatroom in @chatrooms.keys
					p chatroom
					if @chatrooms[chatroom]["ROOM_REF"].to_s == message_hash["LEAVE_CHATROOM"]
						chatroom_name = chatroom
						@chatrooms[chatroom]["MEMBERS"].delete(message_hash["CLIENT_NAME"])
						p "member deleted"
						break
					end
				end
				arg = "LEFT_CHATROOM:#{message_hash["LEAVE_CHATROOM"]}\n" + 
					"JOIN_ID:#{message_hash["JOIN_ID"]}\n"
				p arg

				c.puts(arg)

				arg2 = "CHAT:#{@chatrooms[chatroom_name]["ROOM_REF"]}\n" + 
					"CLIENT_NAME:#{message_hash["CLIENT_NAME"]}\n" + 
					"MESSAGE:#{message_hash["CLIENT_NAME"]} has left this chatroom.\n\n"

				for member in @chatrooms[chatroom_name]["MEMBERS"]
					puts "send #{member} the left message.\n"
					@clients[member][1].puts(arg2)
				end
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
