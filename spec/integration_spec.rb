require_relative "spec_helper"

class A < Jober::Task
  interval 3000

  def perform
    10.times do |i|
      B.enqueue(i)
      C.enqueue(i)
    end
  end
end

class B < Jober::Queue
  interval 3

  def perform(x)
    SO["b"] += x
  end
end

class C < Jober::QueueBatch
  interval 3

  def perform(batch)
    SO["c"] = batch.flatten
  end
end

describe "integration" do
  it "should work" do
    SO["b"] = 0
    run_manager_for(5, [A, B, C])
    SO["b"].should == 45
    SO["c"].should == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  end
end
