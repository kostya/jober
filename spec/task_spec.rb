require_relative "spec_helper"

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
  every 3, :bla
  every 5

  def bla
  end

  def perform
  end
end

describe "Task" do
  it "should execute" do
    w = WorkerTask.new
    w.execute.counter.should == 10
  end

  it "should set short_name" do
    WorkerTask.short_name.should == 'worker'
  end

  it "should register class" do
    Jober.classes.should include(WorkerTask)
  end

  it "set some schedulers" do
    Task2.workers.should == [[3, :bla], [5, :perform]]
  end
end
