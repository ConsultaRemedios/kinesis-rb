module Kinesis
  # The ProducerQueue is used to persists a queue of events to be sent to
  # Kinesis stream.
  #
  # The idea is to keep the state of the queue on redis and it can be shared
  # between multiple processes or threads
  #
  # @example Enqueing events
  #   redis = Redis.new
  #   queue = Kinesis::ProduceQueue.new(redis, 'my-list')
  #   queue.add('event 1')
  #   queue.size => 1
  #
  # @example Processing events
  #   redis = Redis.new
  #   queue = Kinesis::ProduceQueue.new(redis, 'my-list')
  #   queue.process(100) do |events|
  #     events.each { |e| do_something(e) }
  #   end
  class ProducerQueue
    # @param redis [Redis] redis client instance
    # @param key [String] redis key for the list
    def initialize(redis, key)
      @redis = redis
      @key = key
    end

    # Appends event to the tail of queue
    #
    # @param event [String] a string to be enqueued
    # @return the object
    def add(event)
      @redis.rpush @key, event
    end

    # The size of the queue
    #
    # @return [Integer] the size of queue
    def size
      @redis.llen @key
    end

    # Removes N elements from the beginning of queue.
    # When the queue has less than N elements all of elements will be taken from
    # the queue and it will be empty.
    #
    # @param batch_size [Integer] the maximum number of elements to be taken from queue
    # @yield [events] events taken from the queue
    def process(batch_size, &block)
      events, ok = @redis.multi do |multi|
        multi.lrange @key, 0, batch_size - 1
        multi.ltrim @key, batch_size, -1
      end

      block.call(events) if block_given?
    end
  end
end
