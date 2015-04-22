class Jober::UniqueQueue < Jober::Queue

  def self.len
    Jober.redis.scard(queue_name)
  end

  def self.enqueue(*args)
    Jober.redis.sadd(queue_name, Jober.dump(args))
  end

  def pop
    res = Jober.redis.spop(queue_name)
    Jober.load(res) if res
  end

end
