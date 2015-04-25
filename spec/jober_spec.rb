require_relative "spec_helper"

class A1 < Jober::Task; end
class A2 < Jober::Queue; end
class A3 < Jober::QueueBatch; end
class A4 < Jober::UniqueQueue; end

class Jober::B1 < Jober::Task; end

describe "Jober" do
  it "classes" do
    Jober.internal_classes_names.each do |k|
      Jober.classes.should_not include(eval(k))
    end
  end

  it "find_class" do
    Jober.find_class("A1").should == A1
    Jober.find_class("A1234").should == nil
    Jober.find_class("B1").should == Jober::B1
    Jober.find_class("Jober::B1").should == Jober::B1
    Jober.find_class("B2").should == nil
    Jober.find_class("Jober::B2").should == nil
  end
end
