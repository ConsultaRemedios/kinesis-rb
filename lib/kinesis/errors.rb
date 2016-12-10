module Kinesis
  class Error < StandardError; end

  class ThroughputExceededError < Kinesis::Error; end
end
