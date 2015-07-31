class Jober::SlowQueue < Jober::Queue

  # one event per perform
  def run
    if @args = pop
      perform(*@args)
      info { "processed event args: #{args.inspect}" }
    else
      info { "no pending events" }
    end
  end
end
