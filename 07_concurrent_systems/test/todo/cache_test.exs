defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()
    alice_pid = Todo.Cache.server_process(cache, "alice")
    Todo.Server.add_entry(alice_pid, %{date: ~D[2024-05-01], title: "Dentist"})

    entries = Todo.Server.entries(alice_pid, ~D[2024-05-01])
    assert [%{date: ~D[2024-05-01], title: "Dentist"}] = entries
  end
end
