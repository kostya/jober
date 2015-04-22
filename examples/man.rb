require 'bundler/setup'
Bundler.require :default
require_relative 'classes'

man = Jober::Manager.new "test"
man.logger_path = File.expand_path(__dir__)
man.run
