require "#{File.dirname(__FILE__)}/spec_helper"

class MyQueue < Jober::Queue
  def initialize(*args)
    super
    @counter = 0
  end

  attr_reader :counter

  def perform(x)
    @counter += x
  end
end

class Jasdfoadsfjaf < Jober::Queue
  set_queue_name 'human_name'

  def perform
  end
end

describe "Queue" do
  it "should set internals" do
    w = MyQueue.new
    w.queue_name.should == 'Jober::queue:my'
  end

  it "should execute" do
    MyQueue.enqueue(1)
    MyQueue.enqueue(2)
    MyQueue.enqueue(3)
    MyQueue.new.execute.counter.should == 6
  end

  it "should register class" do
    Jober.classes.should include(MyQueue)
  end

  it "custom queue name" do
    10.times { Jasdfoadsfjaf.enqueue }
    Jober.llens['human_name'].should == 10
  end
end
