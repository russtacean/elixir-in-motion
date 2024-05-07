# Implementation of chapter 5 todo_server using genserver
# Multiple modules in the same file for now, will learn to use mix in Chap 7
defmodule TodoServer do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def add_entry(new_entry) do
    GenServer.cast(__MODULE__, {:add_entry, new_entry})
  end

  def delete_entry(entry_id) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end

  def update_entry(entry_id, update_fn) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id, update_fn})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  #### Callback Functions ####
  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, curr_todo_list) do
    {:noreply, TodoList.add_entry(curr_todo_list, new_entry)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, curr_todo_list) do
    {:noreply, TodoList.delete_entry(curr_todo_list, entry_id)}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, update_fn}, curr_todo_list) do
    {:noreply, TodoList.update_entry(curr_todo_list, entry_id, update_fn)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, curr_todo_list) do
    {:reply, TodoList.entries(curr_todo_list, date), curr_todo_list}
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn entry, todo_list_acc ->
        add_entry(todo_list_acc, entry)
      end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)
    %TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, updater_fn) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        # TODO Better error handling
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    new_entries = Map.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end
