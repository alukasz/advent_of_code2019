defmodule AoC2019.Day4 do
  @from 134_564
  @to 585_159

  def count_valid_passwords(from \\ @from, to \\ @to) do
    from..to
    |> Enum.chunk_every(ceil((to - from) / System.schedulers()))
    |> Task.async_stream(fn range ->
      Enum.reduce(range, 0, fn candidate, count ->
        if valid_password?(candidate), do: count + 1, else: count
      end)
    end)
    |> Enum.reduce(0, &(elem(&1, 1) + &2))
  end

  @doc """
  iex> AoC2019.Day4.valid_password?(111111)
  false
  iex> AoC2019.Day4.valid_password?(223450)
  false
  iex> AoC2019.Day4.valid_password?(223434)
  false
  iex> AoC2019.Day4.valid_password?(123789)
  false
  iex> AoC2019.Day4.valid_password?(112233)
  true
  iex> AoC2019.Day4.valid_password?(123444)
  false
  iex> AoC2019.Day4.valid_password?(111122)
  true
  """
  def valid_password?(password) do
    pairs =
      password
      |> Integer.digits()
      |> Enum.chunk_every(2, 1, :discard)

    never_decrease?(pairs) and same_adjacent_digits?(pairs) and
      same_adjacent_digits_not_part_of_larger_group?(pairs)
  end

  defp never_decrease?(pairs) do
    Enum.all?(pairs, fn [a, b] -> a <= b end)
  end

  defp same_adjacent_digits?(pairs) do
    Enum.any?(pairs, fn [a, b] -> a == b end)
  end

  defp same_adjacent_digits_not_part_of_larger_group?(pairs) do
    pairs
    |> Enum.filter(&match?([a, a], &1))
    |> Enum.group_by(& &1)
    # check if any pair occured once
    |> Enum.any?(&match?({_, [_]}, &1))
  end
end
