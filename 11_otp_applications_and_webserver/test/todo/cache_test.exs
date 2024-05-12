defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    bob_pid = Todo.Cache.server_process("bob")

    assert bob_pid != Todo.Cache.server_process("alice")
    assert bob_pid == Todo.Cache.server_process("bob")
  end

  test "to-do operations" do
    alice_pid = Todo.Cache.server_process("alice")
    Todo.Server.add_entry(alice_pid, %{date: ~D[2024-05-01], title: "Dentist"})

    entries = Todo.Server.entries(alice_pid, ~D[2024-05-01])
    assert [%{date: ~D[2024-05-01], title: "Dentist"}] = entries
  end
end
