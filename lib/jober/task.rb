class Jober::Task < Jober::AbstractTask

  def self.extract_name(name)
    Jober.underscore(name).gsub(/_?queue_?/, '').gsub(/_?fk_?/, '').gsub(/_?task_?/, '').split('::').last.gsub('/', '-')
  end

  def self.inherited(base)
    super
    base.short_name = extract_name(base.name)
  end

  def perform
    raise "implement me"
  end

  def run(method)
    send(method)
  end

end
