# Multithreaded_Server


This is a simple multithreaded TCP server with an threadpool to control the number of clients serve at one time. It is writen in Ruby, and the Ruby version is ruby 2.2.3p173.

To start the server, just move to the src folder, and run the "start.sh" script. The default port number is set to be 2000, however it can be changed to any given portnumber by adding the portnumber in the command line, like "start.sh portnumber".
The TCP server has a thread pool of 10 threads by default. To change the number of threads, at present it needed to change the server.rb code at line 30.

If the server gets a message of "KILL_SERVICE\n", it shuts down. If the server gets a message of "HELO text\n", it will return information of  IP, port and the studentID(for safety reasons, I didn't put my real student ID, I put 'oldk' instead). Otherwise, the server will return a message containing which thread is taking care of the requst and the origin message.


filelist:

server.rb 	The main program of the server, including the main loop and handling of the requests.

ThreadPool.rb 	The class of thread pool.

start.sh 	The script to start the server.

client.rb 	A simple TCP client to do the tests.