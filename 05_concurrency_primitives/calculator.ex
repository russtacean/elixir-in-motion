defmodule Calculator do
  def start do
    spawn(fn -> loop(0) end)
  end

  defp loop(current_value) do
    new_value =
      receive do
        message -> process_message(current_value, message)
      end

    loop(new_value)
  end

  defp process_message(current_value, {:value, caller_pid}) do
    send(caller_pid, {:response, current_value})
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:sub, value}) do
    current_value - value
  end

  defp process_message(current_value, {:mul, value}) do
    current_value * value
  end

  defp process_message(current_value, {:div, value}) do
    current_value / value
  end

  defp process_message(current_value, invalid_request) do
    IO.puts("invalid request #{inspect(invalid_request)}")
    current_value
  end

  def value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:response, value} -> value
    end
  end

  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})
end

calculator_pid = Calculator.start()
Calculator.value(calculator_pid)
Calculator.add(calculator_pid, 10)
Calculator.sub(calculator_pid, 5)
Calculator.mul(calculator_pid, 3)
Calculator.div(calculator_pid, 5)
Calculator.value(calculator_pid)
