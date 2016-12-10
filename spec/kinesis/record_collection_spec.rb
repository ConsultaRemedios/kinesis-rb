require 'spec_helper'

describe Kinesis::RecordCollection do
  let(:records) { ['record1', 'record2'] }
  subject { described_class.new(records, 'next123', '998') }

  describe '#records' do
    it 'returns the records' do
      expect(subject.records).to eq records
    end
  end

  describe '#next_shard_iterator' do
    it 'returns the next_shard_iterator' do
      expect(subject.next_shard_iterator).to eq 'next123'
    end
  end

  describe '#last_sequence_number' do
    it 'returns the last_sequence_number' do
      expect(subject.last_sequence_number).to eq '998'
    end
  end

  it 'delegates size to records' do
    expect(records).to receive(:size) { 2 }
    expect(subject.size).to eq 2
  end

  it 'delegates empty? to records' do
    expect(records).to receive(:empty?) { false }
    expect(subject.empty?).to be_falsey
  end

  it 'delegates any? to records' do
    expect(records).to receive(:any?) { true }
    expect(subject.any?).to be_truthy
  end

  it 'delegates first to records' do
    expect(records).to receive(:first) { 'record1' }
    expect(subject.first).to eq 'record1'
  end

  it 'delegates last to records' do
    expect(records).to receive(:last) { 'record2' }
    expect(subject.last).to eq 'record2'
  end

  it 'delegates each to records' do
    expect(records).to receive(:each)
    subject.each
  end

  it 'delegates map to records' do
    expect(records).to receive(:map)
    subject.map
  end

  it 'delegates to_s to records' do
    expect(records).to receive(:to_s) { 'to_s' }
    expect(subject.to_s).to eq 'to_s'
  end
end
