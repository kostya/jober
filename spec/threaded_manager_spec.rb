require "#{File.dirname(__FILE__)}/spec_helper"

class T1 < Jober::Task
  def perform
    SO["t1"] += 1
  end
end

class T2 < Jober::Task
  def perform
    SO["t2"] += 1
  end
end

class T3 < Jober::Task
  def perform
    SO["t3"] += 1
  end
end

class T4 < Jober::Task
  def perform
    loop do
      sleep 0.1
      break if stopped
    end
    SO["t4"] = "yahoo"
  end
end

class T41 < Jober::Task
  interval 1

  def perform
    sleep 1
    SO["t41"] += 1
  end
end

class T5 < Jober::Task
  def perform
    raise :jopa
  end
end

class T6 < Jober::Task
  def perform
    sleep
  end
end

describe Jober::ThreadedManager do
  before :each do
    SO["t1"] = 0
    SO["t2"] = 0
    SO["t3"] = 0
    SO["t41"] = 0
  end

  it "just work" do
    run_threaded_manager_for(0.1, [T1])
    SO["t1"].should == 1
  end

  xit "run multiple identical tasks" do
    run_threaded_manager_for(0.2, [T1, T1, T1])
    SO["t"].should == 3
  end

  it "run multiple tasks" do
    run_threaded_manager_for(0.2, [T1, T2, T3])
    SO["t1"].should == 1
    SO["t2"].should == 1
    SO["t3"].should == 1
  end

  it "task should be stopped by stopped flag" do
    run_threaded_manager_for(0.5, [T4])
    SO["t4"].should == "yahoo"
  end

  it "run multi tasks, but one raised" do
    run_threaded_manager_for(0.5, [T41, T5])
  end

  it "infinite task should be stopped by kill" do
    run_threaded_manager_for(2.5, [T6, T41])
    SO["t41"].should == 2
  end

end
