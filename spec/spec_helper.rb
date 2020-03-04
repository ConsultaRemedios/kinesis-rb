require 'simplecov'
SimpleCov.start
SimpleCov.refuse_coverage_drop

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kinesis'
require 'pry'


class ClientMock
  def shard_iterator(stream_name, shard_id, shard_iterator_type, starting_sequence_number)
    'iterator123'
  end

  def shard_ids(stream_name)
    ['shardId-00000']
  end

  def get_records(shard_iterator, batch_size)
    Kinesis::RecordCollection.new(['data1'], 'nextIterator222', '222', 3600)
  end

  def put_record(stream_name, record, partition_key)
    '999'
  end

  def put_records(stream_name, records)
    '999'
  end
end
