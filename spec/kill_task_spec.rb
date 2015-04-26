require "#{File.dirname(__FILE__)}/spec_helper"

class LongTask1 < Jober::Task
  def perform
    sleep 100
  end
end

class LongTask11 < Jober::Task
  def perform
    while true
      sleep 1
      break if stopped
    end
    SO["11"] = true
  end
end

class LongTask2 < Jober::Queue
  def perform
    sleep 1
    SO["a"] += 1
  end
end

describe "should kill long tasks" do
  it "kill" do
    t = Time.now
    SO["a"] = 0
    100.times { LongTask2.enqueue }

    m = run_manager_for(3, [LongTask1, LongTask11, LongTask2])

    SO["a"].should == 3
    m.pids.should == []
    (Time.now - t).should < (3.2 + 2.5)
    SO["11"].should == true
  end
end
