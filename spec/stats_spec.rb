require_relative "spec_helper"

class MyQueue1 < Jober::Queue
  def perform
    sleep 2
  end
end

class MyQueue2 < Jober::QueueBatch
  def perform
  end
end

describe "Stats" do
  it "llens" do
    10.times { MyQueue1.enqueue }
    99.times { MyQueue2.enqueue }

    h = Jober.llens
    h['my1'].should == 10
    h['my2'].should == 99
  end

  it "stats" do
    MyQueue1.enqueue
    run_manager_for(3, [MyQueue1, MyQueue2])
    h = Jober.stats
    h['my1'][:start].should be
    h['my1'][:end].should be
    h['my1'][:duration].should be_within(0.1).of(2.0)
    h['my2'][:start].should be
    h['my2'][:end].should be
    h['my2'][:duration].should be_within(0.1).of(0.0)
  end
end
