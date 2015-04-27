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
    prox = proxy

    if @worker_id && @workers_count && !@opts[:no_auto_proxy]
      prox = prox.where("id % #{@workers_count} = #{@worker_id}")
    end

    cnt = 0
    count = prox.count
    info { "full count to process #{count}" }

    prox.find_in_batches(:batch_size => self.class.get_batch_size) do |batch|
      res = perform(batch)
      cnt += batch.size
      info { "process batch #{res.inspect}, #{cnt} from #{count}, lastid #{batch.last.id}" }
      break if stopped
    end

    info { "processed total #{cnt}" }
  end
end
