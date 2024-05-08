defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(Todo.Server, nil)
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
  def init(_) do
    {:ok, Todo.List.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, curr_todo_list) do
    {:noreply, Todo.List.add_entry(curr_todo_list, new_entry)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, curr_todo_list) do
    {:noreply, Todo.List.delete_entry(curr_todo_list, entry_id)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_fn}, curr_todo_list) do
    {:noreply, Todo.List.update_entry(curr_todo_list, entry_id, update_fn)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, curr_todo_list) do
    {:reply, Todo.List.entries(curr_todo_list, date), curr_todo_list}
  end
end
