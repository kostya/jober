require_relative "spec_helper"

class MyBatchQueue < Jober::QueueBatch
  batch_size 6

  attr_reader :res

  def perform(batch)
    @res ||= []
    @res << batch
  end
end

describe "QueueBatch" do
  it "should set internals" do
    w = MyBatchQueue.new
    w.queue_name.should == 'Jober::queue:my_batch'
  end

  it "should execute" do
    10.times { |i| MyBatchQueue.enqueue(i) }
    MyBatchQueue.new.execute.res.should == [[[0], [1], [2], [3], [4], [5]], [[6], [7], [8], [9]]]
  end

  it "should register class" do
    Jober.classes.should include(MyBatchQueue)
  end
end
