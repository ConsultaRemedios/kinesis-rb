require 'spec_helper'

describe Kinesis::RecordCollection do
  let(:events) { ['record1', 'record2'] }
  subject { described_class.new(events, 'next123', '998', 10_300_100) }

  describe '#events' do
    it 'returns the events' do
      expect(subject.events).to eq events
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

  describe '#millis_behind_latest' do
    it 'returns the millis_behind_latest' do
      expect(subject.millis_behind_latest).to eq 10_300_100
    end
  end

  describe '#time_behind_latest' do
    it 'returns the time behind latest in hours, minutes and seconds' do
      expect(subject.time_behind_latest).to eq "02:51:40"
    end

    it do
      allow(subject).to receive(:millis_behind_latest) { 1_000  }
      expect(subject.time_behind_latest).to eq "00:00:01"
    end

    it do
      allow(subject).to receive(:millis_behind_latest) { (60 * 1_000) + (10 * 1_000) }
      expect(subject.time_behind_latest).to eq "00:01:10"
    end

    it do
      allow(subject).to receive(:millis_behind_latest) { 60 * 60 * 1_000 }
      expect(subject.time_behind_latest).to eq "01:00:00"
    end
  end

  it 'delegates size to events' do
    expect(events).to receive(:size) { 2 }
    expect(subject.size).to eq 2
  end

  it 'delegates empty? to events' do
    expect(events).to receive(:empty?) { false }
    expect(subject.empty?).to be_falsey
  end

  it 'delegates any? to events' do
    expect(events).to receive(:any?) { true }
    expect(subject.any?).to be_truthy
  end

  it 'delegates first to events' do
    expect(events).to receive(:first) { 'record1' }
    expect(subject.first).to eq 'record1'
  end

  it 'delegates last to events' do
    expect(events).to receive(:last) { 'record2' }
    expect(subject.last).to eq 'record2'
  end

  it 'delegates each to events' do
    expect(events).to receive(:each)
    subject.each
  end

  it 'delegates map to events' do
    expect(events).to receive(:map)
    subject.map
  end

  it 'delegates to_s to events' do
    expect(events).to receive(:to_s) { 'to_s' }
    expect(subject.to_s).to eq 'to_s'
  end
end
