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

			p "message_hash #{message_hash}"

			if message_hash.has_key?("JOIN_CHATROOM")
				p "JOIN_CHATROOM"

				if !(@clients.has_key?(message_hash["CLIENT_NAME"]))
					p 'CLIENT_NAME'
					@join_id += 1
					join_id = @join_id
					@clients[message_hash["CLIENT_NAME"]] = [join_id, c]
				else
					next #to be added with error code
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
					"MESSAGE:#{message_hash["CLIENT_NAME"]} has joined this chatroom.\n"
				p arg2
				for member in @chatrooms[message_hash["JOIN_CHATROOM"]]["MEMBERS"]
					arg2 = "CHAT:#{@chatrooms[message_hash["JOIN_CHATROOM"]]["ROOM_REF"]}\n" + 
					"CLIENT_NAME:#{member}\n" + 
					"MESSAGE:#{message_hash["CLIENT_NAME"]} has joined this chatroom.\n"
					@clients[member][1].puts(arg2)
				end

				next

			end

			if message_hash.has_key?("LEAVE_CHATROOM")

				chatroom = @chatrooms.select{|key, hash| hash["ROOM_REF"] == message_hash["LEAVE_CHATROOM"]}
				chatroom["MEMBERS"].delete(message_hash["CLIENT_NAME"])

				arg = "LEFT_CHATROOM:#{message_hash["LEAVE_CHATROOM"]}\n" + 
					"JOIN_ID:#{message_hash["JOIN_ID"]}\n"
				c.puts(arg)

				for member in chatroom["MEMBERS"]
					arg2 = "CHAT:#{@chatrooms[message_hash["LEAVE_CHATROOM"]]["ROOM_REF"]}\n" + 
						"CLIENT_NAME:member\n" + 
						"MESSAGE:#{message_hash["CLIENT_NAME"]} has joined this chatroom.\n"
					@clients[member][1].puts(arg2)
				end


			end


		end
	end

end

port = 2000
if ARGV.length != 0 
	port = ARGV[0]
end
Server.new(port)
