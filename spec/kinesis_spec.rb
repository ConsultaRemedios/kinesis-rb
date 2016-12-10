require 'spec_helper'

describe Kinesis do
  it 'has a version number' do
    expect(Kinesis::VERSION).not_to be nil
  end

  describe '.client' do
    before do
      Kinesis.configuration.access_key_id = 'access_key'
      Kinesis.configuration.secret_access_key = 'secret_key'
      Kinesis.configuration.region = 'us-west-1'
    end

    it 'instantiates the client using the Kinesis configuration' do
      expect(Kinesis::Client).to receive(:new).with('access_key', 'secret_key', 'us-west-1') { 'instance' }
      expect(Kinesis.client).to eq 'instance'
    end
  end

  describe '.configuration' do
    it 'instantiates the singleton Kinesis::Config' do
      expect(Kinesis.configuration).to eq Kinesis::Config.instance
    end
  end

  describe '.build_producer' do
    it 'instantiates a StreamProducer' do
      expect(Kinesis::StreamProducer).to receive(:new).with('foo') { 'instance' }
      expect(Kinesis.build_producer('foo')).to eq 'instance'
    end
  end

  describe '.build_consumer' do
    let(:storage) { Kinesis.configuration.storage }

    context 'without set storage' do
      it 'instantiates a StreamConsumer' do
        expect(Kinesis::StreamConsumer).to receive(:new).with('foo', storage: storage) { 'instance' }
        expect(Kinesis.build_consumer('foo')).to eq 'instance'
      end
    end

    context 'setting up a storage' do
      it 'instantiates a StreamConsumer using a different storare' do
        expect(Kinesis::StreamConsumer).to receive(:new).with('foo', storage: :some_storage) { 'instance' }
        expect(Kinesis.build_consumer('foo', storage: :some_storage)).to eq 'instance'
      end
    end
  end
end
