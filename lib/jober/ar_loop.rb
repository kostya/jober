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

    prefix = ''

    if @worker_id && @workers_count && @workers_count > 1 && !@opts[:no_auto_proxy]
      cond = "id % #{@workers_count} = #{@worker_id}"
      prox = prox.where(cond)
      prefix += "(#{cond}) "
      info { "sharding enabled '#{cond}'" }
    end

    last_batch_id = if (_last_batch_id = get_store("lastbatch")) && !@opts[:no_last_batch]
      info { "Finded last_batch_id #{_last_batch_id} so start with it!" }
      prefix += "(#{_last_batch_id}:) "
      _last_batch_id
    end

    prox = prox.where(@opts[:where]) if @opts[:where]

    cnt = 0
    count = last_batch_id ? prox.where("id > ?", last_batch_id).count : prox.count
    info { "#{prefix}full count to process #{count}" }

    h = {:batch_size => self.class.get_batch_size}
    h[:start] = last_batch_id + 1 if last_batch_id

    t1 = Time.now
    prox.find_in_batches(h) do |batch|
      t = Time.now

      res = perform(batch)
      cnt += batch.size

      select_time = t - t1
      t1 = Time.now
      process_time = t1 - t

      cnt += batch.size
      info { "#{prefix}process batch #{res.inspect} | #{cnt} from #{count} | lastid #{batch.last.id} (#{format("%.1f", select_time)}s, #{format("%.1f", process_time)}s)" }
      set_store("lastbatch", batch.last.id)
      break if stopped
    end

    reset_last_batch_id unless stopped

    info { "#{prefix}processed total #{cnt} #{summary_info}" }
  end

  def summary_info
    nil
  end

  def reset_last_batch_id
    Jober.redis.del(store_key('lastbatch'))
  end
end
