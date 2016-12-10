require 'logger'

module Kinesis
  class Config
    include Singleton

    attr_accessor :logger,

      # Default consumer batch_size
      :consumer_batch_size,

      # AWS access key id
      :access_key_id,

      # AWS secret access key
      :secret_access_key,

      # AWS region
      :region,

      # Storage type
      # Default Kinesis::Storage::Memory.new
      :storage

    def self.delegated
      public_instance_methods - superclass.public_instance_methods - Singleton.public_instance_methods
    end

    def initialize
      @logger = Logger.new(STDOUT)
      @access_key_id = ENV['AWS_ACCESS_KEY_ID']
      @secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      @region = 'us-east-1'
      @consumer_batch_size = 1_000
      @storage = Kinesis::Storage::Memory.new
    end
  end
end
