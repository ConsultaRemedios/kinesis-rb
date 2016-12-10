require 'spec_helper'

describe Kinesis::StreamConsumer do
  let(:storage) { Kinesis::Storage::Memory.new }
  let(:client) { ClientMock.new }
  let(:shard_consumer) { double(:shard_consumer) }

  subject { described_class.new('foo', storage: storage) }

  before do
    allow(Kinesis).to receive(:client) { client }
  end

  describe '#consume' do
    it 'instantiates the ShardConsumer using de detault batch_size' do
      expect(Kinesis::ShardConsumer).to receive(:new).with('foo', 'shardId-00000', storage) { shard_consumer }
      expect(shard_consumer).to receive(:consume).with(1_000).and_yield(:shard, :records)
      subject.consume { |shard, records| }
    end

    it 'instantiates the ShardConsumer setting up custom batch_size' do
      expect(Kinesis::ShardConsumer).to receive(:new).with('foo', 'shardId-00000', storage) { shard_consumer }
      expect(shard_consumer).to receive(:consume).with(1).and_yield(:shard, :records)
      subject.consume(1) { |shard, records| }
    end
  end
end
