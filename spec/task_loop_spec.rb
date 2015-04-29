require "#{File.dirname(__FILE__)}/spec_helper"

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

class Loop3 < Jober::Task
  interval 3
  def perform
    c = 0
    loop { sleep 1; c += 1; break if stopped || c > 4 }
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
    (st[:finished] - st[:started]).should be_within(0.001).of(0)
    (Time.now - st[:finished]).should be_within(0.7).of(1)
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
    l.stop!
    sleep 0.3
    SO["y"].should == 1
  end

  it "if skip_delay!, should start imidiately" do
    l = Loop2.new
    l.execute
    Loop2.skip_delay!
    t = Thread.new { l.run_loop }
    sleep 2
    l.stop!
    sleep 0.3
    SO["y"].should == 2
  end

  it "if skip_delay by option, should start imidiately" do
    l = Loop2.new(:skip_delay => true)
    l.execute
    t = Thread.new { l.run_loop }
    sleep 2
    l.stop!
    sleep 0.3
    SO["y"].should == 2
  end

  describe "task was finished by itself or by stop!" do
    it "if was finished by itself" do
      l = Loop3.new
      l.execute
      SO["y"].should == 1

      # next run should wait for 3 seconds
      l = Loop3.new
      t = Thread.new { l.run_loop }
      sleep 2
      l.stop!
      sleep 0.3
      SO["y"].should == 1
    end

    it "was stopped in middle, should start next imidiately" do
      l = Loop3.new
      t = Thread.new { l.execute }
      sleep 2
      l.stop!
      sleep 0.3
      SO["y"].should == 1

      # next run should wait for 3 seconds
      l = Loop3.new
      t = Thread.new { l.run_loop }
      sleep 2
      l.stop!
      sleep 0.3
      SO["y"].should == 2
    end
  end

  it "skip_delay!" do
    Loop2.pop_skip_delay_flag!.should == false
    Loop2.skip_delay!
    Loop2.pop_skip_delay_flag!.should == true
    Loop2.pop_skip_delay_flag!.should == false
  end
end
