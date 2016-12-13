module Kinesis
  class ShardConsumer
    extend Forwardable

    attr_reader :shard_id

    def_delegator :checkpointer, :iterator, :current_iterator
    def_delegator :checkpointer, :sequence, :last_sequence

    # @param stream_name [String] the stream name
    # @param shard_id [String] the shard id
    # @param storage [Kinesis::Storage::Memory, Kinesis::Storage::Redis] checkpointer storage
    def initialize(stream_name, shard_id, storage)
      @stream_name = stream_name
      @shard_id = shard_id
      @storage = storage
    end

    # Fetch the records from Kinesis stream shard using the last checkpoint,
    # yields the records and checkpoint the last sequence readed.
    #
    # @param batch_size [Integer] how many records the shard should fetch each time
    # @yield [shard, records] The current shard and records fetched.
    # @raise [Kinesis::ThroughputExceededError]
    # @return the object
    def consume(batch_size, &block)
      start = Time.now
      record_collection = client.get_records(checkpointer.iterator, batch_size)
      puts "Reading #{record_collection.size} records from #{@stream_name}/#{@shard_id}"
      block.call(self, record_collection) if block_given?
      checkpointer.iterator = record_collection.next_shard_iterator unless record_collection.next_shard_iterator.nil?
      checkpointer.persist(record_collection.last_sequence_number) if record_collection.any?

      # Whe the block execution takes less than one second if forces a sleep to
      # avoid throughput limit exception
      sleep 1 if Time.now - start < 1.0
    rescue Aws::Kinesis::Errors::ProvisionedThroughputExceededException
      raise Kinesis::ThroughputExceededError
    end

    private

    def client
      Kinesis.client
    end

    def checkpointer
      @checkpointer ||= Kinesis::Checkpointer.new(@stream_name, @shard_id, @storage)
    end
  end
end