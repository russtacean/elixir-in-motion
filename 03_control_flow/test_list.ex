defmodule TestList do
  def empty?([]), do: true
  def empty?([_ | _]), do: false

  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)
end
