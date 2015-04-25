require_relative "spec_helper"

class AA1 < Jober::Task
  interval 10
end

class AA2 < AA1
  workers 2
end

class AA3 < AA2
  interval 15
end

class AA4 < AA3
end

class Loop1 < Jober::Task
  interval 1
  def perform
    SO["x"] ||= 0
    SO["x"] += 1
  end
end

class Loop2 < Jober::Task
  interval 3
  def perform
    SO["y"] ||= 0
    SO["y"] += 1
  end
end

describe "Task" do
  it "interval interval should be inherited" do
    AA1.get_interval.should == 10
    AA2.get_interval.should == 10
    AA3.get_interval.should == 15
    AA4.get_interval.should == 15
  end

  it "workers should not be inherited" do
    AA1.get_workers.should == 1
    AA2.get_workers.should == 2
    AA3.get_workers.should == 1
  end

  it "run_loop" do
    t = Thread.new { Loop1.new.run_loop }
    sleep 3.5
    t.kill
    SO["x"].should == 4
    st = Jober.stats['loop1']
    (st[:end] - st[:start]).should be_within(0.001).of(0)
    (Time.now - st[:end]).should be_within(0.7).of(1)
  end

  it "run_loop should wait, until interval ready" do
    Loop2.new.execute
    t = Thread.new { Loop2.new.run_loop }
    sleep 4
    t.kill
    SO["y"].should == 2
  end

  it "run_loop should wait, until interval ready" do
    l = Loop2.new
    l.execute
    t = Thread.new { l.run_loop }
    sleep 2
    l.stopped = true
    sleep 0.3
    SO["y"].should == 1
  end
end
