defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(__MODULE__, name)
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
    {:noreply, {name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, curr_todo_list}) do
    new_list = Todo.List.add_entry(curr_todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, curr_todo_list}) do
    {:noreply, {name, Todo.List.delete_entry(curr_todo_list, entry_id)}}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_fn}, {name, curr_todo_list}) do
    {:noreply, {name, Todo.List.update_entry(curr_todo_list, entry_id, update_fn)}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {name, curr_todo_list}) do
    {:reply, Todo.List.entries(curr_todo_list, date), {name, curr_todo_list}}
  end
end
