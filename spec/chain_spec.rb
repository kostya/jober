require_relative "spec_helper"

class MyChain < Jober::Task
  interval 3

  def perform
    sleep 5
    SO["chain"] += 1
  end
end

describe "Queue" do
  it "should work" do
    SO["chain"] = 0
    run_manager_for(7, [MyChain])
    SO["chain"].should == 1
  end
end
