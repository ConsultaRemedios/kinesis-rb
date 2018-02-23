require 'spec_helper'

describe Kinesis::Checkpointer do
  let(:storage) { Kinesis::Storage::Memory.new('foo-id-123' => '555') }
  let(:client) { double(:kinesis_client) }

  subject { described_class.new('foo', 'id-123', storage) }

  before do
    allow(Kinesis).to receive(:client) { client }
    allow(client).to receive(:shard_iterator).with('foo', 'id-123', 'AFTER_SEQUENCE_NUMBER', '555') { '123' }
  end

  describe '#refresh_iterator!' do
    it 'refenerates a new iterator' do
      subject.persist('999')
      expect(client).to receive(:shard_iterator).with('foo', 'id-123', 'AFTER_SEQUENCE_NUMBER', '999') { 'abcd'}
      subject.refresh_iterator!
      expect(subject.iterator).to eq 'abcd'
    end
  end

  describe '#sequence' do
    it 'returns the current sequence' do
      expect(subject.sequence).to eq '555'
    end
  end

  describe '#persist' do
    it 'writes to storage' do
      expect(storage).to receive(:write).with('foo-id-123', '001')
      subject.persist('001')
    end

    it 'updates the sequence' do
      subject.persist('001')
      expect(subject.sequence).to eq '001'
    end
  end

  describe '#iterator=' do
    it 'updates the iterator' do
      subject.iterator = 'new_iterator'
      expect(subject.iterator).to eq 'new_iterator'
    end
  end
end
