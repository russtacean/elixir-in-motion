defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  @impl GenServer
  def init(_) do
    IO.puts("Starting database server.")
    File.mkdir_p!(@db_folder)
    worker_map = init_workers()
    {:ok, worker_map}
  end

  defp init_workers() do
    for idx <- 0..2, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start(@db_folder)
      {idx, pid}
    end
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _, worker_map) do
    worker_key = :erlang.phash2(key, 3)
    {:reply, Map.get(worker_map, worker_key), worker_map}
  end
end
