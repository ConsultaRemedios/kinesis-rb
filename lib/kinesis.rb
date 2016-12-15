require 'singleton'

require 'kinesis/version'
require 'kinesis/storage/memory'
require 'kinesis/storage/redis'
require 'kinesis/config'
require 'kinesis/errors'
require 'kinesis/client'
require 'kinesis/checkpointer'
require 'kinesis/shard_consumer'
require 'kinesis/stream_consumer'
require 'kinesis/stream_producer'
require 'kinesis/producer_queue'
require 'kinesis/queue_manager'

module Kinesis
  class << self
    # The current Kinesis AWS client.
    # It is used to communicate directly to AWS Kinesis api.
    #
    # @return [Kinesis::Client]
    def client
      Thread.current[:kinesis_client] ||= begin
        Kinesis::Client.new(configuration.access_key_id, configuration.secret_access_key, configuration.region)
      end
    end

    def logger
      configuration.logger
    end

    def configuration
      Kinesis::Config.instance
    end

    # Instantiates a StreamProducer for an existing Kinesis stream name.
    #
    # @example
    #   producer = Kinesis.build_producer 'foo'
    #   producer.produce 'some message', 'some_key'
    #
    # @param stream_name [String] the name of Kinesis stream.
    # @return [Kinesis::StreamProducer]
    def build_producer(stream_name)
      Kinesis::StreamProducer.new(stream_name)
    end

    # Instantiates a StreamConsumer for an existing Kinesis stream name.
    #
    # @example
    #   consumer = Kinesis.build_consumer 'foo'
    #   consumer.consume do |shard, records|
    #     process(records)
    #   end
    #
    # @param stream_name [String] the name of Kinesis stream.
    # @param options [Hash] the options to build a consumer with.
    # @option options [Kinesis::Storage::Memory, Kinesis::Storage::Redis] :storage The storage used to checkpoint the comsumed records.
    # @return [Kinesis::StreamConsumer]
    def build_consumer(stream_name, options = {})
      storage = options.fetch(:storage) { current_storage }
      Kinesis::StreamConsumer.new(stream_name, storage: storage)
    end

    private

    def current_storage
      configuration.storage
    end
  end
end
