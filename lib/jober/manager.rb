require 'thread'

class Jober::Manager
  include Jober::Logger

  attr_accessor :logger_path, :stopped

  def initialize(name, allowed_classes = nil)
    @name = name
    @stopped = false
    @mutex = Mutex.new
    @pids = []
    @allowed_classes = allowed_classes ? (Jober.classes & allowed_classes) : Jober.classes

    $0 = "#{@name} manager"
    if @logger_path
      self.logger = ::Logger.new(File.join(@logger_path, "manager.log"))
    end
    info "starting manager #{@name}"
  end

  def run!
    @allowed_classes.each do |klass|
      klass.get_workers.times do |idx|
        Thread.new { start_worker(klass, klass.get_interval, idx, klass.get_workers) }
      end
    end
  end

  def run
    run!

    trap("TERM") { stop }

    loop do
      sleep 1
      break if @stopped
    end
  end

  def stop!
    @stopped = true
    @pids.each { |pid| ::Process.kill("QUIT", pid) }
    info "stopping manager..."
  end

  def stop(timeout = 2.5)
    stop!
    return if @pids.empty?

    sum = 0
    while true
      sleep(0.1)
      sum += 0.1
      break if sum >= timeout
      break if @pids.empty?
    end

    return if @pids.empty?

    info { "still alive pids: #{@pids}, killing" }
    @pids.each { |pid| ::Process.kill("KILL", pid) }

    @pids = []
  end

  def catch
    yield
    true
  rescue Object => ex
    Jober.exception(ex)
    nil
  end

  def start_worker(klass, interval, idx, count)
    debug { "start worker for #{klass.to_s}" }
    loop do
      pid = nil
      res = catch do
        pid = run_task_fork(klass, idx, count)
        add_pid(pid)
        Process.wait(pid)
        del_pid(pid)
        sleep interval unless stopped
      end
      del_pid(pid)
      break if stopped
      sleep 0.5 unless res
      break if stopped
    end
  end

  def run_task_fork(klass, idx, count)
    info "invoke #{klass}"
    fork do
      $0 = "#{@name} manager #{klass}"
      #$0 += " #{index}" if index > 0
      Jober.call_after_fork
      Jober.reset_redis

      inst = klass.new(idx, count) # class_name parent of Jober::Task

      if @logger_path
        logger_path = File.join(@logger_path, "#{klass.short_name}.log")

        STDOUT.reopen(File.open(logger_path, 'a'))
        STDERR.reopen(File.open(logger_path, 'a'))
        inst.logger = ::Logger.new(logger_path)
      end

      inst.execute
    end
  end

  def pids
    @mutex.synchronize { @pids }
  end

private

  def add_pid(pid)
    @mutex.synchronize { @pids << pid }
  end

  def del_pid(pid)
    @mutex.synchronize { @pids -= [pid] }
  end

  def clear_pids
    @mutex.synchronize { @pids = [] }
  end
end
