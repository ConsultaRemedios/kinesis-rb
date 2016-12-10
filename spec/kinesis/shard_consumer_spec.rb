require 'spec_helper'

describe Kinesis::ShardConsumer do
  let(:storage) { Kinesis::Storage::Memory.new }
  let(:client) { ClientMock.new }

  before do
    allow(Kinesis).to receive(:client) { client }
  end

  subject { described_class.new('foo', 'shardId-00000', storage) }

  describe '#consume' do
    context 'when raise Aws::Kinesis::Errors::ProvisionedThroughputExceededException' do
      it 'raises Kinesis::ThroughputExceededError' do
        allow(client).to receive(:get_records).and_raise(Aws::Kinesis::Errors::ProvisionedThroughputExceededException.new('context', 'message'))
        expect { subject.consume(1) }.to raise_error(Kinesis::ThroughputExceededError)
      end
    end

    it 'updates checkpointer' do
      subject.consume(1)
      expect(subject.current_iterator).to eq 'nextIterator222'
      expect(subject.last_sequence).to eq '222'
    end

    it 'updates the storage' do
      subject.consume(1)
      expect(storage.read('foo-shardId-00000')).to eq '222'
    end

    it 'executes the block' do
      subject.consume(1) do |shard, records|
        expect(shard).to eq subject
        expect(records.size).to eq 1
        expect(records.first).to eq 'data1'
      end
    end
  end
end
