require 'rubygems'
require 'bundler/setup'
Bundler.require

$summary = 0

class Bench < Jober::Queue
  def perform(x, y)
    $summary += x + y
  end
end

Jober.logger = Logger.new nil

t = Time.now
threads = []
5.times do |ti|
  threads << Thread.new do
    10000.times { |i| Bench.enqueue(i + ti * 10000, -(i + ti * 10000 ) / 2.0) }
  end
end
threads.map(&:join)
puts Time.now - t
puts Bench.len

t = Time.now
Bench.new.execute
puts Time.now - t

puts $summary
puts Bench.len
