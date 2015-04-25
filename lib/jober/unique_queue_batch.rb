require "#{File.dirname(__FILE__)}/queue_batch"

class Jober::UniqueQueueBatch < Jober::UniqueQueue
  include Jober::QueueBatchFeature
end
