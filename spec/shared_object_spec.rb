require "#{File.dirname(__FILE__)}/spec_helper"

describe "SO" do
  it "should work" do
    SO["a"].should == nil
    SO["a"] = 0
    SO["a"].should == 0
    SO["a"] += 1
    SO["a"].should == 1

    SO["b"].should == nil
    SO["b"] = [1, 2, 3, :bla, {"a" => 2.5}]
    SO["b"].should == [1, 2, 3, :bla, {"a" => 2.5}]

    SO.del("a")
    SO["a"].should == nil

    SO.clear
    SO["b"].should == nil

    SO["c"] ||= 0
    SO["c"] += 1
    SO["c"].should == 1
  end
end
