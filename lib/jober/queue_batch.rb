module Jober::QueueBatchFeature
  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    def batch_size(bs)
      @batch_size = bs
    end

    def get_batch_size
      @batch_size ||= 100
    end
  end

  module InstanceMethods
    def run
      cnt = 0
      batch = []
      while args = pop
        batch << args
        if batch.length >= self.class.get_batch_size
          execute_batch(batch)
          info { "execute batch #{batch.length}, #{cnt} from #{len}" }
          batch = []
        end
        break if stopped
        cnt += 1
      end
      if batch.length > 0
        if stopped
          reschedule_batch(batch)
        else
          execute_batch(batch)
        end
      end
      info { "processes total #{cnt} " }
      self
    end

    def execute_batch(batch)
      perform(batch)
    rescue Object => ex
      reschedule_batch(batch)
      exception(ex)
    end

  private

    def reschedule_batch(batch)
      batch.reverse_each { |ev| Jober.redis.lpush(queue_name, Jober.dump(ev)) }
    end

  end
end

class Jober::QueueBatch < Jober::Queue
  include Jober::QueueBatchFeature
end
