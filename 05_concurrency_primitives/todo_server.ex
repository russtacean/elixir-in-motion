defmodule TodoServer do
  def start do
    pid = spawn(fn -> loop(TodoList.new()) end)
    Process.register(pid, :todo)
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  defp process_message(todo_list, {:update_entry, entry_id, updater_fn}) do
    TodoList.update_entry(todo_list, entry_id, updater_fn)
  end

  defp process_message(todo_list, {:entries, caller_pid, date}) do
    send(caller_pid, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, invalid_message) do
    IO.puts("unknown message: #{inspect(invalid_message)}")
    todo_list
  end

  def add_entry(new_entry) do
    send(:todo, {:add_entry, new_entry})
  end

  def delete_entry(entry_id) do
    send(:todo, {:delete_entry, entry_id})
  end

  def update_entry(entry_id, updater_fn) do
    send(:todo, {:update_entry, entry_id, updater_fn})
  end

  def entries(date) do
    send(:todo, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end
end

# Both modules in the same file for now, will learn to use mix in Chap 7
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
