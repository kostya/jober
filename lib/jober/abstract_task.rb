class Jober::AbstractTask
  include Jober::Logger

  class << self
    def every(interval, method = :perform)
      workers << [interval, method]
    end

    def workers
      @workers ||= []
    end

    attr_accessor :short_name
  end

  attr_accessor :stopped

  def self.inherited(base)
    Jober.add_class(base)
  end

  def initialize
    @stopped = false
    trap("QUIT") { @stopped = true }
    trap("INT")  { @stopped = true }
  end

  def execute(method = :perform)
    info "=> starting"
    @start_at = Time.now
    write_timestamp(:start)
    run(method)
    write_timestamp(:end)
    info "<= end of #{method} in #{Time.now - @start_at}"
    self
  end

private

  def write_timestamp(type)
    Jober.redis.set(Jober.key("stats:#{self.class.short_name}:#{type}"), Time.now.to_i.to_s)
  rescue Object => ex
    error "#{ex.inspect} #{ex.backtrace}"
  end

end
