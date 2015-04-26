class Jober::Task < Jober::AbstractTask

  def self.extract_name(name)
    Jober.underscore(name).gsub(/[_\/]?queue[_\/]?/, '').gsub(/[_\/]?task[_\/]?/, '').gsub(/[_\/]?jober[_\/]?/, '')
  end

  def self.inherited(base)
    super
    base.short_name = extract_name(base.name)
  end

  def perform
    raise "implement me"
  end

  def run
    perform
  end

end
