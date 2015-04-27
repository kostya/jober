class Jober::ARLoop < Jober::Task
  class << self
    def batch_size(bs)
      @batch_size = bs
    end

    def get_batch_size
      @batch_size ||= 1000
    end
  end

  def proxy
    raise "implement me, should return AR.proxy, ex: User.where('years > 18')"
  end

  def run
    cnt = 0
    count = proxy.count
    info { "full count to process #{count}" }

    proxy.find_in_batches(:batch_size => self.class.get_batch_size) do |batch|
      perform(batch)
      cnt += batch.size
      info { "process batch #{cnt} from #{count}" }
      break if stopped
    end

    info { "processed total #{cnt}" }
  end
end
