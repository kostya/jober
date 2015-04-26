require 'timeout'

class Jober::AbstractTask
  include Jober::Logger

  class << self
    def interval(interval)
      @interval = interval
    end

    def get_interval
      @interval || Jober.default_interval
    end

    def workers(n)
      @workers = n
    end

    def get_workers
      @workers || 1
    end

    attr_accessor :short_name
  end

  attr_accessor :stopped

  def self.inherited(base)
    Jober.add_class(base)
    base.interval(self.get_interval)
  end

  # opts:
  #   :worker_id
  #   :workers_count
  #   :skip_
  def initialize(opts = {})
    @stopped = false
    trap("QUIT") { @stopped = true }
    trap("INT")  { @stopped = true }
    @worker_id = opts[:worker_id] || 0
    @workers_count = opts[:workers_count] || 1
  end

  def execute
    info "=> start"
    @start_at = Time.now
    self.class.write_timestamp(:started)
    run
    self.class.write_timestamp(:finished)
    self.class.del_timestamp(:crashed)
    info "<= end (in #{Time.now - @start_at})"
    self
  rescue Object
    self.class.write_timestamp(:crashed)
    raise
  end

  def run_loop
    info { "running loop" }

    # wait until interval + last end
    if self.class.get_workers <= 1 && (finished = self.class.read_timestamp(:finished)) && (Time.now - finished < self.class.get_interval)
      sleeping(self.class.get_interval - (Time.now - finished))
    end

    # main loop
    loop do
      break if stopped
      execute
      break if stopped
      sleeping
      break if stopped
    end

    info { "quit loop" }
  end

  def sleeping(int = self.class.get_interval)
    info { "sleeping for %.1fm ..." % [int / 60.0] }
    Timeout.timeout(int.to_f) do
      loop do
        sleep 0.3
        return if stopped
      end
    end
  rescue Timeout::Error
  end

private

  def self.timestamp_key(type)
    Jober.key("stats:#{short_name}:#{type}")
  end

  def self.reset_timestamps
    del_timestamp :started
    del_timestamp :finished
  end

  def self.read_timestamp(type)
    Jober.catch do
      res = Jober.redis.get(timestamp_key(type))
      Time.at(res.to_i) if res
    end
  end

  def self.write_timestamp(type)
    Jober.catch do
      Jober.redis.set(timestamp_key(type), Time.now.to_i.to_s)
    end
  end

  def self.del_timestamp(type)
    Jober.catch do
      Jober.redis.del(timestamp_key(type))
    end
  end

end
