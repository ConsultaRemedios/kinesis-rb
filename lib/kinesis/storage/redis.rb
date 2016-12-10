module Kinesis
  module Storage
    class Redis
      def initialize(redis, options = {})
        @redis = redis
        @prefix = options.fetch(:prefix, '')
        @name = 'kinesis'
        @semaphore = Mutex.new
      end

      def write(key, value)
        @semaphore.synchronize { @redis.hset(@name, "#{@prefix}#{key}", value) }
      end

      def read(key)
        @semaphore.synchronize { @redis.hget(@name, "#{@prefix}#{key}") }
      end
    end
  end
end
