class Jober::ThreadedManager
  include Jober::Logger
  include Jober::Exception

  def default_sleep=(ds)
    @default_sleep = ds
  end

  def default_sleep
    @default_sleep ||= 10
  end

  def initialize(klasses = nil, opts = {})
    @klasses = Array(klasses || Jober.auto_classes)
    @stopped = false
    h = Hash.new(0)
    @objects = @klasses.map do |klass|
      if klass.is_a?(String)
        klass_str = klass
        klass = Jober.find_class(klass_str)
        raise "unknown class #{klass_str}" unless klass
      end
      obj = klass.new(opts.merge(:unique_id => h[klass]))
      h[klass] += 1
      obj
    end
  end

  def set_objects(objects)
    c = 0
    objects.each { |o| o.instance_variable_set(:@unique_id, c); c += 1 }
    @objects = objects
  end

  def run_loop
    info { "run loop for #{@klasses.inspect}, in threads: #{@objects.length}" }
    @threads = @objects.map { |obj| make_thread(obj) }

    # set signals
    trap("INT") { @stopped = true }
    trap("QUIT") { @stopped = true }

    # sleeping infinitely
    sleeping

    info { "prepare quit ..." }

    # send stop to all objects
    @objects.each(&:stop!)

    # sleep a little
    sleep(0.2)

    # sleep a little to give time for threads to quit
    wait_for_kill(default_sleep.to_f)

    names = not_finished_objects_names
    if names.empty?
      info { "quit!" }
    else
      info { "quit! and force killing #{names.inspect}" }
    end

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

  def not_finished_objects_names
    @objects.select { |o| o.finished == false }.map { |o| o.class.name }
  end

  def wait_for_kill(interval)
    info { "waiting quiting jobs (#{not_finished_objects_names.inspect}) for %.1fm ..." % [interval / 60.0] }
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
        obj.catch { obj.run_loop }
        break if @stopped
        sleep 1.0
      end
    end
  end
end
