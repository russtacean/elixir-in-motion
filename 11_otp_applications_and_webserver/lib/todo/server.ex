defmodule Todo.Server do
  # Temporary strategy means we don't restart process if it crashes
  # This prevents errors from stacking at the cache supervisor which would cause it to restart
  # improving overall availability
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(name) do
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  def update_entry(todo_server, entry_id, update_fn) do
    GenServer.cast(todo_server, {:delete_entry, entry_id, update_fn})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  @impl GenServer
  def init(name) do
    IO.puts("Starting to-do server for #{name}")
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, curr_todo_list}) do
    new_list = Todo.List.add_entry(curr_todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, curr_todo_list}) do
    {
      :noreply,
      {name, Todo.List.delete_entry(curr_todo_list, entry_id)},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_fn}, {name, curr_todo_list}) do
    {
      :noreply,
      {name, Todo.List.update_entry(curr_todo_list, entry_id, update_fn)},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, curr_todo_list}) do
    {
      :reply,
      Todo.List.entries(curr_todo_list, date),
      {name, curr_todo_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end
end
