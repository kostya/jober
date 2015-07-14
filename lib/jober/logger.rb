require 'logger'

module Jober::Logger
  def logger
    @logger ||= Jober.logger
  end

  def logger=(logger)
    @logger = logger
  end

  def logger_tag
    @logger_tag ||= begin
      tag = '[' + self.class.to_s
      tag += "(#{unique_id})" if respond_to?(:unique_id) && unique_id.to_i > 0
      tag += " #{@worker_id}-#{@workers_count}" if @worker_id && @workers_count && @workers_count > 1
      tag += ']'
      tag
    end
  end

  Logger::Severity.constants.each do |level|
    method_name = level.to_s.downcase

    class_eval <<-Q
      def #{method_name}(msg = nil, &block)
        if block
          logger.send(:#{method_name}) { "\#{logger_tag} \#{block.call}" }
        else
          logger.send(:#{method_name}, "\#{logger_tag} \#{msg}", &block)
        end
      end
    Q
  end
end
