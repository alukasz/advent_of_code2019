defmodule AoC2019.Day4 do
  @from 134_564
  @to 585_159

  def count_valid_passwords(from \\ @from, to \\ @to) do
    Enum.reduce(from..to, 0, fn password_candidate, count ->
      if valid_password?(password_candidate), do: count + 1, else: count
    end)
  end

  @doc """
  iex> AoC2019.Day4.valid_password?(111111)
  true
  iex> AoC2019.Day4.valid_password?(223450)
  false
  iex> AoC2019.Day4.valid_password?(223434)
  false
  iex> AoC2019.Day4.valid_password?(123789)
  false
  """
  def valid_password?(password) do
    password_digits =
      password
      |> to_string()
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)

    same_adjacent_digits?(password_digits) and never_decrease?(password_digits)
  end

  defp same_adjacent_digits?(password_digits) do
    password_digits
    # -1 as leftover to match [a, b] and not false positive Enum.any?/2
    |> Enum.chunk_every(2, 1, [-1])
    |> Enum.any?(fn [a, b] -> a == b end)
  end

  defp never_decrease?(password_digits) do
    password_digits
    # last digit as leftover to match [a, b] and not false negative Enum.all?/2
    |> Enum.chunk_every(2, 1, [List.last(password_digits)])
    |> Enum.all?(fn [a, b] -> a <= b end)
  end
end
