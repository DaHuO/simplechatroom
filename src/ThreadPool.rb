require 'thread'

class ThreadPool
	def initialize(size)
		@size = size
		@jobs = Queue.new

		@pool = Array.new(@size) do |i|
			Thread.new {
				Thread.current[:id] = i
				catch(:exit) do
					loop do
						args, job = @jobs.pop
						job.call(*args)
					end
				end
			}
		end
	end

	def schedule(*args, &block)
		@jobs << [args, block]
	end

	def shutdown
		@size.times do
			schedule{throw :exit}
		end

		@pool.map(&:join)
	end

end