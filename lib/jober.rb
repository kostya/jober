require "jober/version"

require 'redis'
require 'logger'

module Jober
  autoload :Manager,          'jober/manager'
  autoload :AbstractTask,     'jober/abstract_task'
  autoload :Task,             'jober/task'
  autoload :Queue,            'jober/queue'
  autoload :QueueBatch,       'jober/queue_batch'
  autoload :UniqueQueue,      'jober/unique_queue'
  autoload :Logger,           'jober/logger'
  autoload :SharedObject,     'jober/shared_object'
  autoload :UniqueQueueBatch, 'jober/unique_queue_batch'
  autoload :ARLoop,           'jober/ar_loop'

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
      @internal_classes_names ||= (%w{Manager AbstractTask Task Queue} +
        %w{QueueBatch UniqueQueue UniqueQueueBatch Logger SharedObject ARLoop}).map { |k| "Jober::#{k}" }
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
      logger.error "#{ex.message} #{ex.backtrace}"
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
        h[klass.queue_name_base] = klass.len
      end
      h
    end

    def stats
      h = {}
      @classes.each do |klass|
        started = klass.read_timestamp(:started)
        finished = klass.read_timestamp(:finished)
        crashed = klass.read_timestamp(:crashed)
        h[klass.short_name] = {
          :started => started,
          :finished => finished,
          :crashed => crashed,
          :duration => (finished && started && finished >= started) ? (finished - started) : nil
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
      klass_name = "Jobs::#{klass_name}"
      return eval(klass_name) if names.include?(klass_name)
    end

    def skip_delay!
      classes.each &:skip_delay!
    end

    def default_interval
      @default_interval ||= 5 * 60
    end

    def default_interval=(di)
      @default_interval = di
    end

    def enqueue(queue_name, *args)
      Jober.redis.rpush(queue_name, Jober.dump_args(*args))
    end

    def catch(&block)
      yield
    rescue Object => ex
      Jober.exception(ex)
      nil
    end
  end
end

# just empty module for store tasks
module Jobs
end
