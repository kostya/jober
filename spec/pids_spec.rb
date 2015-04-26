require "#{File.dirname(__FILE__)}/spec_helper"

class Man1 < Jober::Task
  interval 2

  def perform
    sleep 3
  end
end

class Man2 < Jober::Task
  interval 2

  def perform
    sleep 2
    raise "jopa"
  end
end

describe "manage pids" do
  it "should work" do
    run_manager_for(nil, [Man1, Man2]) do |m|
      sleep 1
      m.pids.size.should == 2

      sleep 1.5
      m.pids.size.should == 1

      sleep 1
      m.pids.size.should == 0

      sleep 1
      m.pids.size.should == 1

      sleep 1.1
      m.pids.size.should == 2
    end

    st = Jober.stats
    st['man1'][:crashed].should_not be
    st['man2'][:crashed].should be

    st['man1'][:finished].should be
    st['man2'][:finished].should_not be
  end
end
