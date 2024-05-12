defmodule Todo.System do
  def start_link do
    Supervisor.start_link(
      # Order matters here, so processes must be started before their dependents
      [
        Todo.Metrics,
        Todo.Database,
        Todo.Cache,
        Todo.Web
      ],
      strategy: :one_for_one
    )
  end
end
