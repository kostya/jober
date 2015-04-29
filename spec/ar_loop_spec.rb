require "#{File.dirname(__FILE__)}/spec_helper"
require "active_record"

class MyAR < Jober::ARLoop
  batch_size 10

  def proxy
    User.where("years > 18")
  end

  def perform(batch)
    SO["names"] += batch.map(&:name)
    batch.size
  end
end

class MyAR2 < Jober::ARLoop
  batch_size 10

  def proxy
    User.where("years > 18")
  end

  def perform(batch)
    sleep 1
    SO["names"] += batch.map(&:name)
    batch.size
  end
end

conn = { 'adapter' => 'sqlite3', 'database' => File.dirname(__FILE__) + "/test.db" }
ActiveRecord::Base.establish_connection conn
#ActiveRecord::Base.logger = Logger.new(STDOUT)

def pg_create_schema
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Migration.create_table :users do |t|
    t.string :name
    t.integer :years
  end
end

def pg_drop_data
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Migration.drop_table :users
end

def create_data
  100.times do |i|
    User.create! :name => "unknown #{i}", :years => i % 36 + 1
  end
end

class User < ActiveRecord::Base; end

describe "ARLoop" do
  before :all do
    pg_drop_data rescue nil
    pg_create_schema
    create_data
  end

  before :each do
    SO["names"] = []
  end

  it "should work" do
    MyAR.new.execute
    SO["names"].size.should == 46
    SO["names"].last.should == "unknown 99"
  end

  it "use auto proxy sharding" do
    MyAR.new(:worker_id => 1, :workers_count => 4).execute
    SO["names"].size.should == 10
    SO["names"].last.should == "unknown 96"
  end

  it "where" do
    MyAR.new(:where => "years < 24").execute
    SO["names"].size.should == 15
    SO["names"].last.should == "unknown 94"
  end

  it "should use lastbatch" do
    my = MyAR2.new
    Thread.new { my.execute }
    sleep 1.5
    my.stop!
    sleep 0.6

    SO["names"].size.should == 20
    SO["names"].last.should == "unknown 55"

    # should start from last ID
    my = MyAR2.new
    my.execute
    SO["names"].size.should == 46
    SO["names"].last.should == "unknown 99"
  end

  it "should not use lastbatch, if it was dropped" do
    my = MyAR2.new
    Thread.new { my.execute }
    sleep 1.5
    my.stop!
    sleep 0.6

    SO["names"].size.should == 20
    SO["names"].last.should == "unknown 55"

    # should start from last ID
    my = MyAR2.new
    my.reset_last_batch_id
    my.execute
    SO["names"].size.should == 66
  end

  it "should not start from lastbatch if task was finished by itself, not by stop" do
    my = MyAR2.new
    my.execute
    SO["names"].size.should == 46

    # should start from zero
    my = MyAR2.new
    my.execute
    SO["names"].size.should == 46 + 46
  end
end
