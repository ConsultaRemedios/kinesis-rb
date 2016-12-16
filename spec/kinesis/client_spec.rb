require 'spec_helper'

describe Kinesis::Client do
  let(:client_class) { double(:client_class) }
  let(:client) { double(:client) }

  before do
    expect(client_class).to receive(:new).with(access_key_id: '111', secret_access_key: '222', region: 'us-east-1') { client }
  end

  subject { described_class.new('111', '222', 'us-east-1', client_class: client_class) }

  describe '#shard_iterator' do
    let(:shard_iterator_params) do
      {
        stream_name: 'foo',
        shard_id: 'shardId-00000001',
        shard_iterator_type: 'TRIM_HORIZON',
        starting_sequence_number: '12345'
      }
    end

    let(:response) { double(:response, shard_iterator: '553456dfgdfgv') }

    it 'returns the shard_iterator string' do
      expect(client).to receive(:get_shard_iterator).with(shard_iterator_params) { response }
      expect(subject.shard_iterator('foo', 'shardId-00000001', 'TRIM_HORIZON', '12345')).to eq '553456dfgdfgv'
    end
  end

  describe '#shard_ids' do
    let(:shard_description) { double(:shard_description, shard_id: 'shardId-00000001') }
    let(:stream_description) { double(:stream_description, shards: [shard_description]) }
    let(:response) { double(:response, stream_description: stream_description) }

    it 'returns all an array with the ids of all shards from stream' do
      expect(client).to receive(:describe_stream).with(stream_name: 'foo') { response }
      expect(subject.shard_ids('foo')).to eq ['shardId-00000001']
    end
  end

  describe '#get_records' do
    let(:data) { Base64.encode64(Zlib::Deflate.deflate('test 1')) }
    let(:record) { double(:record, data: data, sequence_number: '0009898')}
    let(:response) { double(:response, records: [record], next_shard_iterator: 'NextIterator2', millis_behind_latest: 3600) }

    before do
      allow(client).to receive(:get_records).with(shard_iterator: '553456dfgdfgv', limit: 1) { response }
    end

    it 'return records' do
      expect(subject.get_records('553456dfgdfgv', 1).events).to eq ['test 1']
    end

    it 'return next shard iterator' do
      expect(subject.get_records('553456dfgdfgv', 1).next_shard_iterator).to eq 'NextIterator2'
    end

    it 'return last sequence number' do
      expect(subject.get_records('553456dfgdfgv', 1).last_sequence_number).to eq '0009898'
    end

    it 'return millis behind latest' do
      expect(subject.get_records('553456dfgdfgv', 1).millis_behind_latest).to eq 3600
    end
  end

  describe '#put_record' do
    let(:data) { Base64.encode64(Zlib::Deflate.deflate('bar 123')) }
    let(:response) { double(:response, sequence_number: '5557') }

    it 'send the record to stream' do
      expect(client).to receive(:put_record).with(stream_name: 'foo', data: data, partition_key: 'key') { response }
      expect(subject.put_record('foo', 'bar 123', 'key')).to eq '5557'
    end
  end

  describe '#put_records' do
    let(:data) { Base64.encode64(Zlib::Deflate.deflate('test123')) }
    let(:record_response) { double(:record_response, sequence_number: '1112') }
    let(:response) { double(:response, records: [record_response]) }
    let(:record) do
      {
        data: data,
        partition_key: 'key'
      }
    end

    it 'send the record to stream' do
      expect(client).to receive(:put_records).with(stream_name: 'foo', records: [record]) { response }
      expect(subject.put_records('foo', ['test123'], 'key')).to eq '1112'
    end
  end
end
