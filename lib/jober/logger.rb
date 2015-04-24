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

    class_eval <<-Q
      def #{method_name}(msg = nil, &block)
        if block
          logger.send(:#{method_name}) { "[\#{self.class.to_s}] \#{block.call}" }
        else
          logger.send(:#{method_name}, "[\#{self.class.to_s}] \#{msg}", &block)
        end
      end
    Q
  end
end
