require "#{File.dirname(__FILE__)}/spec_helper"

class WorkerTask < Jober::Task
  def initialize(*args)
    super
    @counter = 0
  end

  attr_reader :counter

  def perform
    10.times { @counter += 1 }
  end
end

class Task2 < Jober::Task
  interval 15
  workers 2
  def perform
  end
end

class Jober::Bla < Jober::Task
end

describe "Task" do
  it "should execute" do
    w = WorkerTask.new
    w.execute.counter.should == 10
  end

  it "should set short_name" do
    WorkerTask.short_name.should == 'worker'
    Jober::Bla.short_name.should == 'bla'
  end

  it "should register class" do
    Jober.classes.should include(WorkerTask)
  end

  it "set some settings" do
    Task2.get_workers.should == 2
    Task2.get_interval.should == 15
  end
end
