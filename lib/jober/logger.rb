require 'logger'

module Jober::Logger
  def logger
    @logger ||= Jober.logger
  end

  def logger=(logger)
    @logger = logger
  end

  Logger::Severity.constants.each do |level|
    method_name = level.to_s.downcase
    define_method method_name do |msg = nil, &block|
      logger.send(method_name, msg, &block)
    end
  end
end
