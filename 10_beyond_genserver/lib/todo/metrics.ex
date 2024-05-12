defmodule Todo.Metrics do
  use Task

  def start_link(_arg), do: Task.start_link(&loop/0)

  defp loop() do
    # Lets us perform this task periodically without the need for
    # a cron job or the like. Ideally we'd have a separate scheduler
    # process, so that job logging faults wouldn't take down the scheduler
    Process.sleep(:timer.seconds(10))
    IO.inspect(collect_metrics())
    loop()
  end

  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
