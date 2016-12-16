module Kinesis
  class RecordCollection
    extend Forwardable

    attr_reader :events, :next_shard_iterator, :last_sequence_number, :millis_behind_latest

    def_delegators :events, :size, :empty?, :any?, :all?, :first, :last, :to_s,
                   :each, :map, :group_by, :reduce, :inject, :detect, :find,
                   :find_all, :reject

    def initialize(events, next_shard_iterator, last_sequence_number, millis_behind_latest)
      @events = events
      @next_shard_iterator = next_shard_iterator
      @last_sequence_number = last_sequence_number
      @millis_behind_latest = millis_behind_latest
    end

    def time_behind_latest
      hours = ((millis_behind_latest / (1_000 * 60 * 60)) % 24).to_s.rjust(2, '0')
      minutes = ((millis_behind_latest / (1_000 * 60)) % 60).to_s.rjust(2, '0')
      seconds = ((millis_behind_latest / 1_000) % 60).to_s.rjust(2, '0')
      "#{hours}:#{minutes}:#{seconds}"
    end
  end
end
