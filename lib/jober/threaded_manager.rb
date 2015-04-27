class Jober::ThreadedManager
  include Jober::Logger

  def default_sleep=(ds)
    @default_sleep = ds
  end

  def default_sleep
    @default_sleep ||= 10
  end

  def initialize(klasses, opts = {})
    @klasses = klasses
    @stopped = false
    @objects = @klasses.map do |klass|
      klass = Jober.find_class(klass) if klass.is_a?(String)
      klass.new(opts)
    end
  end

  def run_loop
    info { "run loop for #{@klasses}, in threads: #{@objects.length}" }
    @threads = @objects.map { |obj| make_thread(obj) }

    # set signals
    trap("INT") { @stopped = true }
    trap("QUIT") { @stopped = true }

    # sleeping infinitely
    sleeping

    info { "prepare quit ..." }

    # send stop to all objects
    @objects.each(&:stop!)

    # sleep a little to give time for threads to quit
    wait_for_kill(default_sleep.to_f)

    info { "quit!" }

    # kill all threads, if they still alive
    @threads.select(&:alive?).each(&:kill)
  end

  def stop!
    @stopped = true
  end

private

  def sleeping
    loop do
      sleep 0.5
      return if @stopped
    end
  end

  def wait_for_kill(interval)
    info { "waiting quiting jobs for %.1fm ..." % [interval / 60.0] }
    Timeout.timeout(interval.to_f) do
      loop do
        sleep 0.3
        return if @threads.none? &:alive?
      end
    end
  rescue Timeout::Error
  end

  def make_thread(obj)
    Thread.new do
      loop do
        break if @stopped
        Jober.catch do
          obj.run_loop
        end
        break if @stopped
        sleep 0.5
      end
    end
  end
end
