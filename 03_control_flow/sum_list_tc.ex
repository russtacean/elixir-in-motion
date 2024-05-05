defmodule ListHelper do
  def sum(list) do
    do_sum(0, list)
  end

  defp do_sum(current_sum, []), do: current_sum

  defp do_sum(current_sum, [head | tail]), do: do_sum(head + current_sum, tail)

  def list_len(list) do
    len(0, list)
  end

  defp len(curr_len, []), do: curr_len
  defp len(curr_len, [_head | tail]), do: len(curr_len + 1, tail)

  def range(from, to) do
    rng([], from, to)
  end

  defp rng(curr_list, from, from), do: curr_list ++ [from]

  defp rng(currlist, from, to) when is_integer(from) and is_integer(to) and from < to do
    rng(currlist ++ [from], from + 1, to)
  end

  def positive(list) do
    pos([], list)
  end

  defp pos(pos_list, []), do: pos_list

  defp pos(pos_list, [head | tail]) do
    if head > 0 do
      pos(pos_list ++ [head], tail)
    else
      pos(pos_list, tail)
    end
  end
end
