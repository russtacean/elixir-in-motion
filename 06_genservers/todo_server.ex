# Implementation of chapter 5 todo_server using generic server process from server_process.ex
# Multiple modules in the same file for now, will learn to use mix in Chap 7
defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )

        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request,
            current_state
          )

        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
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

# NEW CODE HERE
defmodule TodoServer do
  #### Interface Functions ####
  def start do
    ServerProcess.start(TodoServer)
  end

  def add_entry(pid, new_entry) do
    ServerProcess.cast(pid, {:add_entry, new_entry})
  end

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end

  def update_entry(pid, entry_id, update_fn) do
    ServerProcess.cast(pid, {:delete_entry, entry_id, update_fn})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  #### Callback Functions ####
  def init do
    TodoList.new()
  end

  def handle_cast({:add_entry, new_entry}, curr_todo_list) do
    TodoList.add_entry(curr_todo_list, new_entry)
  end

  def handle_cast({:delete_entry, entry_id}, curr_todo_list) do
    TodoList.delete_entry(curr_todo_list, entry_id)
  end

  def handle_cast({:update_entry, entry_id, update_fn}, curr_todo_list) do
    TodoList.update_entry(curr_todo_list, entry_id, update_fn)
  end

  def handle_call({:entries, date}, curr_todo_list) do
    {TodoList.entries(curr_todo_list, date), curr_todo_list}
  end
end
