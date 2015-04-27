require "bundler/setup"
Bundler.require :default

Jober::SharedObject
SO = Jober::SharedObject

Jober.logger = Logger.new("#{File.dirname(__FILE__)}/spec.log")

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }

  config.before(:each) do
    SO.clear
    Jober.redis.keys("Jober*").each { |k| Jober.redis.del(k) }
  end

  config.after(:all) do
    SO.clear
  end
end

def run_manager_for(timeout, classes, &block)
  m = Jober::Manager.new "test", classes
  m.run!

  if block
    block.call(m)
  else
    sleep timeout
  end

  m.stop
  sleep 0.1
  m
end

def run_threaded_manager_for(timeout, classes, &block)
  m = Jober::ThreadedManager.new classes
  t = Thread.new do
    m.run_loop
  end

  if block
    block.call(m)
  else
    sleep timeout
  end

  m.stop!
  t.join
  m
end
