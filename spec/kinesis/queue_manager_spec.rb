require 'spec_helper'
require 'redis'

describe Kinesis::QueueManager do
  let(:redis) { Redis.current }
  let(:key) { 'test-queue' }
  let(:queue) { Kinesis::ProducerQueue.new(redis, key) }
  let(:producer) { double(:producer) }

  subject { described_class.new(producer, queue, interval: 1, batch_size: 3) }

  before do
    redis.del key
  end

  after do
    redis.del key
  end

  describe '#execute' do
    context 'when queue is empty' do
      it 'does not calls produce when there are not events to be processed' do
        expect(producer).to_not receive(:multi_produce)
        subject.execute
      end
    end

    context 'when timeout' do
      before do
        queue.add('test')
      end

      it 'produces after timeout' do
        expect(producer).to receive(:multi_produce).with(['test'])
        subject.execute
      end
    end

     context 'when does not timeout' do
      before do
        5.times { |i| queue.add(i.to_s) }
      end

      it 'produces after timeout' do
        expect(producer).to receive(:multi_produce).with(%w(0 1 2))
        subject.execute
        expect(producer).to receive(:multi_produce).with(%w(3 4))
        subject.execute
      end
    end
  end
end
