module Kinesis
  module Storage
    class Memory
      attr_reader :data

      def initialize(initial_state = {})
        @data = initial_state
        @semaphore = Mutex.new
      end

      def write(key, value)
        @semaphore.synchronize { @data[key] = value }
      end

      def read(key)
        @semaphore.synchronize { @data[key] }
      end
    end
  end
end
