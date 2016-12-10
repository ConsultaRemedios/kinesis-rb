module Kinesis
  class StreamConsumer
    attr_reader :stream_name

    # @param stream_name [String] the name of stream
    # @param options [Hash] the options
    # @option options [Kinesis::Storage::Memory, Kinesis::Storage::Redis] :storage
    def initialize(stream_name, options = {})
      @stream_name = stream_name
      @storage = options.fetch(:storage) { Kinesis::Storage::Memory.new }
      @shards = build_shards
    end

    # Loops over all shards fetching records from the stream yielding for
    # every block of records from each shard.
    #
    # @param batch_size [Integer] the number of records to read each time per shard
    # @yield [shard, records] Gives the shard and the records fetched from the shard
    def consume(batch_size = 1_000, &block)
      @shards.each do |shard|
        shard.consume(batch_size, &block)
      end
    end

    private

    def client
      Kinesis.client
    end

    def build_shards
      shard_ids.map do |shard_id|
        Kinesis::ShardConsumer.new(@stream_name, shard_id, @storage)
      end
    end

    def shard_ids
      client.shard_ids(stream_name)
    end
  end
end
