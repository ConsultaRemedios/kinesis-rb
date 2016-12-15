module Kinesis
  class RecordCollection
    extend Forwardable

    attr_reader :events, :next_shard_iterator, :last_sequence_number

    def_delegators :events, :size, :empty?, :any?, :all?, :first, :last, :to_s,
                   :each, :map, :group_by, :reduce, :inject, :detect, :find,
                   :find_all, :reject

    def initialize(events, next_shard_iterator, last_sequence_number)
      @events = events
      @next_shard_iterator = next_shard_iterator
      @last_sequence_number = last_sequence_number
    end
  end
end
