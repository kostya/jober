class Jober::SharedObject
  class << self
    def set(name, obj, conn = Jober.redis)
      conn.set(key(name), Marshal.dump(obj))
    end

    def get(name, conn = Jober.redis)
      r = conn.get(key(name))
      Marshal.load(r) if r
    end

    def raw_get(name)
      Jober.redis.get(key(name))
    end

    def [](name)
      get(name)
    end

    def []=(name, obj)
      set name, obj
    end

    def inc(name, by = 1)
      Jober.redis.incrby(key(name), by)
    end

    def del(name)
      Jober.redis.del key(name)
    end

    def clear
      Jober.redis.keys(key('*')).each { |k| del(k) }
    end

    def values(mask)
      Jober.redis.keys(key(mask)).map { |key| get(key) }
    end

    def key(name)
      if name.start_with?('shared:')
        name
      else
        "shared:#{name}"
      end
    end
  end
end
