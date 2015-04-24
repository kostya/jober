class Jober::Queue < Jober::Task

  def self.inherited(base)
    super
    base.set_queue_name(base.short_name)
  end

  class << self
    attr_accessor :queue_name

    def set_queue_name(q)
      @queue_name = Jober.key("queue:#{q}")
    end
  end

  def queue_name
    self.class.queue_name
  end

  def self.enqueue(*args)
    Jober.redis.rpush(queue_name, Jober.dump_args(*args))
  end

  def self.len
    Jober.redis.llen(self.queue_name)
  end

  def len
    self.class.len
  end

  def pop
    res = Jober.redis.lpop(queue_name)
    Jober.load(res) if res
  end

  def run
    cnt = 0
    while args = pop
      perform(*args)
      cnt += 1

      if stopped
        break
      end

      info { "processed #{cnt}" } if cnt % 1000 == 0
    end
    info { "processed total #{cnt}" }
  end
end
