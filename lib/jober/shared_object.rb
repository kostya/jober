class Jober::SharedObject
  class << self
    def set(name, obj, conn = Jober.redis)
      Jober.catch do
        conn.set(key(name), Marshal.dump(obj))
      end
    end

    def get(name, conn = Jober.redis)
      Jober.catch do
        r = conn.get(key(name))
        Marshal.load(r) if r
      end
    end

    def get_by_pure_key(name, conn = Jober.redis)
      Jober.catch do
        r = conn.get(name)
        Marshal.load(r) if r
      end
    end

    def raw_get(name)
      Jober.catch do
        Jober.redis.get(key(name))
      end
    end

    def [](name)
      get(name)
    end

    def []=(name, obj)
      set name, obj
    end

    def inc(name, by = 1)
      Jober.catch do
        Jober.redis.incrby(key(name), by)
      end
    end

    def del(name)
      Jober.catch do
        Jober.redis.del key(name)
      end
    end

    def clear
      Jober.catch do
        Jober.redis.keys(key('*')).each { |k| Jober.redis.del(k) }
      end
    end

    def keys(mask)
      Jober.catch do
        Jober.redis.keys(key(mask))
      end
    end

    def values(mask)
      Jober.catch do
        Jober.redis.keys(key(mask)).map { |key| get_by_pure_key(key) }
      end
    end

    def key(name)
      k = if name.start_with?('shared:')
        name
      else
        "shared:#{name}"
      end
      Jober.key(k)
    end
  end
end
