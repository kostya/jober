require_relative "spec_helper"

class A1 < Jober::Task; end
class A2 < Jober::Queue; end
class A3 < Jober::QueueBatch; end
class A4 < Jober::UniqueQueue; end

describe "Jober" do
  it "classes" do
    Jober.internal_classes_names.each do |k|
      Jober.classes.should_not include(eval(k))
    end
  end
end
