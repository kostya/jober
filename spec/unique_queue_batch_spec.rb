require_relative "spec_helper"

class MyUniqueBatchQueue < Jober::UniqueQueueBatch
  batch_size 6

  attr_reader :res

  def perform(batch)
    @res ||= []
    @res << batch
  end
end

describe "QueueBatch" do
  it "should set internals" do
    w = MyUniqueBatchQueue.new
    w.queue_name.should == 'Jober::queue:my_unique_batch'
  end

  it "should execute" do
    10.times { |i| 10.times { MyUniqueBatchQueue.enqueue(i) } }
    MyUniqueBatchQueue.new.execute.res.flatten.sort.should == (0..9).to_a
  end

  it "should register class" do
    Jober.classes.should include(MyUniqueBatchQueue)
  end
end
