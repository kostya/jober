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

conn = { 'adapter' => 'sqlite3', 'database' => File.dirname(__FILE__) + "/test.db" }
ActiveRecord::Base.establish_connection conn

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
end
