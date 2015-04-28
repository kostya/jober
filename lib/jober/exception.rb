module Jober::Exception

  def exception(ex)
    msg = self.respond_to?(:logger_tag) ? "#{self.logger_tag} #{ex.message}" : ex.message
    ex2 = ex.class.new(msg)
    ex2.set_backtrace(ex.backtrace)
    Jober.exception(ex2)
  end

  def catch(&block)
    yield
  rescue Object => ex
    exception(ex)
    nil
  end
end
