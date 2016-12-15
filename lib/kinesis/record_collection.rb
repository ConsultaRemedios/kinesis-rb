module Kinesis
  class RecordCollection
    extend Forwardable

    attr_reader :events, :next_shard_iterator, :last_sequence_number

    def_delegators :events, :size, :empty?, :any?, :first, :last, :each, :map, :to_s

    def initialize(events, next_shard_iterator, last_sequence_number)
      @events = events
      @next_shard_iterator = next_shard_iterator
      @last_sequence_number = last_sequence_number
    end
  end
end
