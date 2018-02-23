module Kinesis
  class Checkpointer
    extend Forwardable

    attr_accessor :iterator
    attr_reader :sequence

    # @param stream_name [String] the stream name
    # @param shard_id [String] the shard id
    # @param storage [Kinesis::Storage::Memory, Kinesis::Storage::Redis] the storage
    def initialize(stream_name, shard_id, storage)
      @stream_name = stream_name
      @shard_id = shard_id
      @storage = storage
      @sequence = fetch_sequence
      @iterator = fetch_iterator
    end

    # @param sequence [String] persists the sequence to storage
    def persist(sequence)
      logger.debug "[Kinesis] checkpoint created! #{storage_key}: #{sequence}"
      @storage.write(storage_key, sequence)
      @sequence = sequence
    end

    def refresh_iterator!
      @iterator = fetch_iterator
    end

    private

    def logger
      Kinesis.logger
    end

    def client
      Kinesis.client
    end

    def fetch_sequence
      @storage.read(storage_key)
    end

    def storage_key
      "#{@stream_name}-#{@shard_id}"
    end

    def iterator_type
      sequence_present? ? 'AFTER_SEQUENCE_NUMBER' : 'LATEST'
    end

    def sequence_present?
      !sequence_blank?
    end

    def sequence_blank?
      @sequence.nil? || @sequence == ''
    end

    def fetch_iterator
      client.shard_iterator(@stream_name, @shard_id, iterator_type, @sequence)
    end
  end
end
