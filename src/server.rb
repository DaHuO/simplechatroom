load "ThreadPool.rb"
require 'socket'
require 'net/http'

def handle_client(c, count, server)
	student_id = 'oldk'
	while input = c.gets
		p c.remote_address.ip_address

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

		message = input.split('\n')
		p message

	end
end
uri = URI('http://ipecho.net/plain')
body = Net::HTTP.get(uri)
if body.length!=0
	$ip = body
else
	$ip = '127.0.0.1'
end
if ARGV.length != 0 
	$port = ARGV[0]
end
server = TCPServer.open($port)
thread_pool = ThreadPool.new(5)	#to create a thread pool with 10 threads
# puts 'got the thread_pool'
count = 0
while server
	puts server.class
	client = server.accept
	thread_pool.schedule(client) do |c|
		count += 1
		handle_client(c, count, server)
	end
end
