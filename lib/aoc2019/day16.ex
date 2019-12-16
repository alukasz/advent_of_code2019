defmodule AoC2019.Day16 do
  @day 16

  @pattern [0, 1, 0, -1]

  @doc """
  iex> AoC2019.Day16.fft("12345678", 4)
  "01029498"
  iex> AoC2019.Day16.fft("80871224585914546619083218645595", 100)
  "24176176"
  """
  def fft(input \\ AoC2019.read(@day), phases \\ 100)

  def fft(input, phases) when is_binary(input) do
    input
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> fft(phases)
  end

  def fft(input, 0) when is_list(input) do
    Enum.join(input, "")
  end

  def fft(input, phases) when is_list(input) do
    input
    |> phase()
    |> fft(phases - 1)
  end

  defp phase(input) do
    input
    |> Enum.with_index(1)
    |> Enum.map(fn {_, n} ->
      input
      |> Enum.zip(pattern(n))
      |> Enum.reduce(0, fn {a, b}, acc -> a * b + acc end)
      |> Kernel.rem(10)
      |> abs()
    end)
  end

  @doc """
  iex> AoC2019.Day16.pattern(1) |> Enum.take(6)
  [1, 0, -1, 0, 1, 0]
  iex> AoC2019.Day16.pattern(2) |> Enum.take(14)
  [0, 1, 1, 0, 0, -1, -1, 0, 0, 1, 1, 0, 0, -1]
  iex> AoC2019.Day16.pattern(3) |> Enum.take(12)
  [0, 0, 1, 1, 1, 0, 0, 0, -1, -1, -1, 0]
  """
  def pattern(n) do
    @pattern
    |> Enum.flat_map(&List.duplicate(&1, n))
    |> Stream.cycle()
    |> Stream.drop(1)
  end
end
