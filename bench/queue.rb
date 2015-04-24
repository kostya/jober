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
50000.times { |i| Bench.enqueue(i, -i / 2.0) }
puts Time.now - t
puts Bench.len

t = Time.now
Bench.new.execute
puts Time.now - t

puts $summary
puts Bench.len
