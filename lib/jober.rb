require "jober/version"

require 'redis'
require 'logger'

module Jober
  autoload :Manager,      'Jober/manager'
  autoload :AbstractTask, 'Jober/abstract_task'
  autoload :Task,         'Jober/task'
  autoload :Queue,        'Jober/queue'
  autoload :QueueBatch,   'Jober/queue_batch'
  autoload :UniqueQueue,  'Jober/unique_queue'
  autoload :Logger,       'Jober/logger'
  autoload :SharedObject, 'Jober/shared_object'

  class << self
    attr_accessor :redis_config
    attr_reader :classes

    def logger
      ::Logger.new(STDOUT)
    end

    def redis
      Thread.current[:__redis__] ||= Redis.new(redis_config || {})
    end

    def reset_redis
      Thread.current[:__redis__] = nil
    end

    def add_class(klass)
      unless %w{Manager AbstractTask Task Queue QueueBatch UniqueQueue Logger SharedObject}.map { |k| "Jober:#{k}" } .include?(klass.to_s)
        @classes ||= []
        @classes << klass
      end
    end

    def after_fork(&block)
      @after_fork = block
    end

    def call_after_fork
      @after_fork.call if @after_fork
    end

    def dump(obj)
      Marshal.dump(obj)
    end

    def load(obj)
      Marshal.load(obj)
    end

    def exception(ex)
      # redefine me
    end

    def underscore(str)
      word = str.dup
      word.gsub!('::', '/')
      word.gsub!(/(?:([A-Za-z\d])|^)((?=a)b)(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    def llens
      h = {}
      @classes.each do |klass|
        next unless klass.ancestors.include?(Jober::Queue)
        h[klass.short_name] = klass.len
      end
      h
    end

    def stats
      h = {}
      @classes.each do |klass|
        start = Jober.redis.get(key("stats:#{klass.short_name}:start"))
        start = Time.at(start.to_i) if start
        _end = Jober.redis.get(key("stats:#{klass.short_name}:end"))
        _end = Time.at(_end.to_i) if _end
        h[klass.short_name] = {:start => start, :end => _end, :duration => (_end && start && _end >= start) ? (_end - start) : nil }
      end
      h
    end

    attr_accessor :namespace

    def key(k)
      "Jober:#{@namespace}:#{k}"
    end
  end
end
