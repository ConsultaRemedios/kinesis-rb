module Kinesis
  class StreamProducer
    # @param stream_name [String] the name of stream
    def initialize(stream_name)
      @stream_name = stream_name
    end

    # Sends the record to the Kinesis stream
    #
    # @param record [String] data to send to Kinesis stream
    # @param partition_key [Integer] used by Kinesis to group the same key always to the same shard
    # @return [String] the sequence number
    def produce(record, partition_key = 'key')
      client.put_record(@stream_name, record.to_s, partition_key)
    end

    # Sends the collection of records using only one api call
    #
    # @param records [Array<String>] collection of data to be sent to Kinesis stream
    # @param partition_key [Integer] used by Kinesis to group the same key always to the same shard
    # @return the object
    def multi_produce(records, partition_key = 'key')
      client.put_records(@stream_name, records, partition_key)
    end

    private

    def client
      Kinesis.client
    end
  end
end
