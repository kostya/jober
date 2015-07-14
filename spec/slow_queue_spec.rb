require "#{File.dirname(__FILE__)}/spec_helper"

class MySlowQueue < Jober::SlowQueue
  interval 0.5
  def perform(x)
    $slow_counter += x
  end
end

describe "SlowQueue" do
  before { $slow_counter = 0 }

  it "should set internals" do
    w = MySlowQueue.new
    w.queue_name.should == 'Jober::queue:my_slow'
  end

  it "should execute" do
    MySlowQueue.enqueue(1)
    MySlowQueue.enqueue(2)
    MySlowQueue.enqueue(3)
    MySlowQueue.new.execute
    $slow_counter.should == 1
  end

  it "run_loop" do
    MySlowQueue.enqueue(1)
    MySlowQueue.enqueue(2)
    MySlowQueue.enqueue(3)
    t = Thread.new do
      MySlowQueue.new.run_loop
    end
    sleep 0.1
    $slow_counter.should == 1
    sleep 0.6
    $slow_counter.should == 3
    sleep 0.6
    $slow_counter.should == 6
    t.kill
  end

end
