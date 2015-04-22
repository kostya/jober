require_relative "spec_helper"

class TestQ1 < Jober::Queue
end

describe "use namespace for keys" do
  it "should work" do
    TestQ1.queue_name.should == 'Jober::queue:test_q1'
    Jober.namespace = "bla"
    TestQ1.set_queue_name(TestQ1.short_name)
    TestQ1.queue_name.should == 'Jober:bla:queue:test_q1'
    Jober.namespace = nil
    TestQ1.set_queue_name(TestQ1.short_name)
    TestQ1.queue_name.should == 'Jober::queue:test_q1'
  end
end
