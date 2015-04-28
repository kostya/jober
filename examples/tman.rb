require 'bundler/setup'
Bundler.require :default
require_relative 'classes'

man = Jober::ThreadedManager.new
man.run_loop
