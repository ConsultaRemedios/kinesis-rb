module Kinesis
  class RecordCollection
    extend Forwardable

    attr_reader :records, :next_shard_iterator, :last_sequence_number

    def_delegators :records, :size, :empty?, :any?, :first, :last, :each, :map, :to_s

    def initialize(records, next_shard_iterator, last_sequence_number)
      @records = records
      @next_shard_iterator = next_shard_iterator
      @last_sequence_number = last_sequence_number
    end
  end
end
