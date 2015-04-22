require_relative "spec_helper"

class FkMyParallel < Jober::Queue
  5.times { |i| every 3 }

  def perform(arg)
    SO["fork:#{$$}"] ||= 0
    SO["fork:#{$$}"] += 1
    SO.inc("count", arg)
  end
end

describe "Queue" do
  it "should work" do
    1000.times { |i| FkMyParallel.enqueue(i) }
    run_manager_for(2, [FkMyParallel])
    SO.raw_get("count").to_i.should == 499500

    vals = SO.values("fork*")
    vals.size.should == 5
    vals.all? { |el| el > 20 }.should == true
    vals.inject(0, :+).should == 1000
  end
end
