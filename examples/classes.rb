require 'bundler/setup'
Bundler.require :default

class A < Jober::Task
  interval 10
  def perform
    10.times do |i|
      info "enqueue to b #{i}"
      B.enqueue(i)
    end
  end
end

class B < Jober::Queue
  interval 10
  def perform(x)
    10.times do |i|
      info "enqueue to c #{x} #{i}"
      C.enqueue(x, i)
    end
  end
end

class C < Jober::Queue
  interval 10
  def perform(x, i)
    10.times do |j|
      info "enqueue to d #{x} #{i} #{j}"
      D.enqueue(x, i, j)
    end
  end
end

class D < Jober::QueueBatch
  interval 10
  batch_size 200

  def perform(*batch)
    info "got batch: #{batch.inspect}"
  end
end

class E < Jober::Task
  interval 5
  workers 5

  def perform
    puts "start e :)"
    sleep 3
  end
end

class G < Jober::Task
  interval 10

  def perform
    "asdfsdf" + 1
  end
end

class F < Jober::Task
  interval 5
  def perform
    sleep 100
  end
end

if $0 == __FILE__
  require 'irb'
  require 'irb/completion'

  IRB.start
end
