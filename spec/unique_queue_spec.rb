require "#{File.dirname(__FILE__)}/spec_helper"

class MyUniqueQueue < Jober::UniqueQueue
  def initialize(*args)
    super
    @counter = 0
  end

  attr_reader :counter

  def perform(x)
    @counter += x
  end
end

describe "Queue" do
  it "should set internals" do
    w = MyUniqueQueue.new
    w.queue_name.should == 'Jober::queue:my_unique'
  end

  it "should execute Only for unique values" do
    MyUniqueQueue.enqueue(1)
    MyUniqueQueue.enqueue(2)
    MyUniqueQueue.enqueue(2)
    MyUniqueQueue.enqueue(2)
    MyUniqueQueue.enqueue(3)
    MyUniqueQueue.enqueue(3)
    MyUniqueQueue.enqueue(3)
    MyUniqueQueue.len.should == 3
    MyUniqueQueue.new.execute.counter.should == 6
  end

end
