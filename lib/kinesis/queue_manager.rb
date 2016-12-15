module Kinesis
  class QueueManager
    # @param producer [Kinesis::StreamProducer] the producer instance
    # @param queue [Kinesis::ProducerQueue] a queue
    # @param options [Hash] options
    # @option interval [Integer] :interval the time interval in seconds to try to produce
    # @option batch_size [Integer] :batch_size the number of elements to produce each time
    def initialize(producer, queue, options = {})
      @producer = producer
      @queue = queue
      @interval = options.fetch(:interval) { 10 }
      @batch_size = options.fetch(:batch_size) { 1_000 }
    end

    # Fetches the batch_size elements from the queue, but it the queue has no enough
    # elements it will wait the interval then use the elements on the queue
    def execute
      Timeout::timeout(@interval) do
        while !ready? do
          sleep 1
        end
      end
    rescue Timeout::Error
    ensure
      produce
    end

    private

    def ready?
      @queue.size >= @batch_size
    end

    def logger
      Kinesis.logger
    end

    def produce
      @queue.process(@batch_size) do |events|
        if events.any?
          logger.info("[Kinesis] producing #{events.size} events")
          @producer.multi_produce(events)
        end
      end
    end
  end
end
