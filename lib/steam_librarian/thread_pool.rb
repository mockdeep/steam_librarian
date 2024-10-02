Thread.abort_on_exception = true

class SteamLibrarian::ThreadPool

  attr_accessor :queue, :results, :result_index, :thread_count, :threads

  def self.open(thread_count:)
    # :nocov:
    throw ArgumentError, 'must pass a block' unless block_given?
    # :nocov:

    pool = new(thread_count:)

    yield(pool)

    pool.close
    pool.results
  end

  def initialize(thread_count:)
    self.queue = Queue.new
    self.results = []
    self.result_index = 0
    self.thread_count = thread_count

    self.threads =
      Array.new(thread_count) do
        Thread.new do
          loop do
            index, block = queue.pop
            result = block.call
            break if result == :__exit_thread__

            results[index] = result
          end
        end
      end
  end

  def close
    thread_count.times { push { :__exit_thread__ } }
    threads.each(&:join)
  end

  def push(&block)
    # :nocov:
    throw ArgumentError, 'must pass a block' unless block
    # :nocov:

    queue.push([result_index, block])
    self.result_index += 1
  end

end
