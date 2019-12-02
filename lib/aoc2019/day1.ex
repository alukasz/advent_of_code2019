defmodule AoC2019.Day1 do
  def fuel_required do
    AoC2019.input(1)
    |> Stream.map(&String.to_integer/1)
    |> Stream.map(&fuel_required/1)
    |> Enum.sum()
  end

  @doc """
  iex> AoC2019.Day1.fuel_required(14)
  2
  iex> AoC2019.Day1.fuel_required(100756)
  50346
  """
  def fuel_required(mass, total_fuel \\ 0) do
    case fuel_for(mass) do
      fuel when fuel < 0 -> total_fuel
      fuel -> fuel_required(fuel, total_fuel + fuel)
    end
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
