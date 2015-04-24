require 'timeout'

class Jober::AbstractTask
  include Jober::Logger

  class << self
    def interval(interval)
      @interval = interval
    end

    def get_interval
      @interval || 5 * 60
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

  def initialize
    @stopped = false
    trap("QUIT") { @stopped = true }
    trap("INT")  { @stopped = true }
  end

  def execute
    info "=> start"
    @start_at = Time.now
    self.class.write_timestamp(:start)
    run
    self.class.write_timestamp(:end)
    info "<= end (in #{Time.now - @start_at})"
    self
  end

  def run_loop
    info { "running loop" }

    # wait until interval + last end
    if self.class.get_workers <= 1 && (_end = self.class.read_timestamp(:end)) && (Time.now - _end < self.class.get_interval)
      sleeping(self.class.get_interval - (Time.now - _end))
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
        sleep 0.2
        return if stopped
      end
    end
  rescue Timeout::Error
  end

private

  def self.timestamp_key(type)
    Jober.key("stats:#{short_name}:#{type}")
  end

  def self.read_timestamp(type)
    res = Jober.redis.get(timestamp_key(type))
    Time.at(res.to_i) if res
  rescue Object => ex
  end

  def self.write_timestamp(type)
    Jober.redis.set(timestamp_key(type), Time.now.to_i.to_s)
  rescue Object => ex
    error "#{ex.inspect} #{ex.backtrace}"
  end

end
