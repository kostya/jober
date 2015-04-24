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
    def logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def logger=(l)
      @logger = l
    end

    def redis
      @redis ||= Redis.new
    end

    def redis=(r)
      @redis = r
    end

    def internal_classes_names
      @internal_classes_names ||= %w{Manager AbstractTask Task Queue QueueBatch UniqueQueue Logger SharedObject}.map { |k| "Jober::#{k}" }
    end

    def classes
      @classes ||= []
    end

    def add_class(klass)
      classes << klass unless internal_classes_names.include?(klass.to_s)
    end

    def after_fork(&block)
      @after_fork = block
    end

    def call_after_fork
      @after_fork.call if @after_fork
    end

    def reset_redis
      redis.client.reconnect
    end

    def dump(obj)
      Marshal.dump(obj)
    end

    def load(obj)
      Marshal.load(obj)
    end

    def dump_args(*args)
      dump(args)
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
        _start = klass.read_timestamp(:start)
        _end = klass.read_timestamp(:end)
        h[klass.short_name] = {
          :start => _start, 
          :end => _end, 
          :duration => (_end && _start && _end >= _start) ? (_end - _start) : nil 
        }
      end
      h
    end

    attr_accessor :namespace

    def key(k)
      "Jober:#{@namespace}:#{k}"
    end

    def find_class(klass_name)
      names = classes.map(&:to_s)
      return eval(klass_name) if names.include?(klass_name)
      klass_name = "Jober::#{klass_name}"
      return eval(klass_name) if names.include?(klass_name)
    end
  end
end

# just empty module for store tasks
module Jobs
end