defmodule Todo.System do
  def start_link do
    Supervisor.start_link(
      # Order matters here, so processes must be started before their dependents
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache
      ],
      strategy: :one_for_one
    )
  end
end
