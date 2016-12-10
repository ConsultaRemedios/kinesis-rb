require 'kinesis/record_collection'
require 'aws-sdk'

module Kinesis
  class Client
    def initialize(access_key_id, secret_access_key, region, options = {})
      @access_key_id = access_key_id
      @secret_access_key = secret_access_key
      @region = region
      @client_class = options.fetch(:client_class) { Aws::Kinesis::Client }
    end

    def shard_iterator(stream_name, shard_id, shard_iterator_type, starting_sequence_number)
      resp = client.get_shard_iterator(
        stream_name: stream_name,
        shard_id: shard_id,
        shard_iterator_type: shard_iterator_type,
        starting_sequence_number: starting_sequence_number)
      resp.shard_iterator
    end

    def shard_ids(stream_name)
      client.
        describe_stream(stream_name: stream_name).
        stream_description.
        shards.
        map { |shard| shard.shard_id }
    end

    def get_records(shard_iterator, batch_size)
      resp = client.get_records(shard_iterator: shard_iterator, limit: batch_size)
      last_sequence = resp.records.last&.sequence_number
      record_data = resp.records.map(&:data)
      Kinesis::RecordCollection.new(record_data, resp.next_shard_iterator, last_sequence)
    end

    def put_record(stream_name, record, partition_key)
      resp = client.put_record(
        stream_name: stream_name,
        data: record,
        partition_key: partition_key)
      resp.sequence_number
    end

    def put_records(stream_name, records)
      resp = client.put_records(
        stream_name: stream_name,
        records: records)
      resp.records.last&.sequence_number
    end

    private

    def client
      @client ||= @client_class.new(
          access_key_id: @access_key_id,
          secret_access_key: @secret_access_key,
          region: @region)
    end
  end
end
