require 'spec_helper'
require 'redis'

describe Kinesis::ProducerQueue do
  let(:redis) { Redis.current }
  let(:key) { 'test-queue' }

  subject { described_class.new(redis, key) }

  before do
    redis.del key
  end

  after do
    redis.del key
  end

  describe '#add' do
    it 'increase the size of the queue' do
      expect(subject.size).to eq 0
      subject.add('foo')
      expect(subject.size).to eq 1
    end
  end

  describe '#process' do
    context 'when queue is empty' do
      it 'executes the block with an empty array' do
        subject.process(1) do |events|
          expect(events).to be_empty
        end
      end
    end

    context 'when queue is not empty' do
      before do
        10.times { |i| subject.add("#{i}") }
      end

      context 'when request less elements than the size of the queue' do
        it 'it returns only the number of elements on the queue' do
          subject.process(5) do |events|
            expect(events).to eq %w(0 1 2 3 4)
          end
        end

        it 'removes the elements read from the queue' do
          subject.process(7) { |_| }
          expect(subject.size).to eq 3
        end
      end

      context 'when request more elements than the size of the queue' do
        it 'it returns only the number of elements on the queue' do
          subject.process(100) do |events|
            expect(events.size).to eq 10
          end
        end

        it 'clears the queue after the block' do
          subject.process(100) { |_| }
          expect(subject.size).to eq 0
        end
      end
    end
  end
end
