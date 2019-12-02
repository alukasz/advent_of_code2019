defmodule AoC2019.Day1 do
  def fuel_required do
    AoC2019.input(1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&fuel_for/1)
    |> Enum.sum()
  end

  @doc """
  iex> AoC2019.Day1.fuel_for(14)
  2
  iex> AoC2019.Day1.fuel_for(100756)
  33583
  """
  def fuel_for(mass) do
    Kernel.trunc(mass / 3) - 2
  end
end
