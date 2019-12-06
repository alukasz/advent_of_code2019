defmodule AoC2019.Day6 do
  @day 6
  @center_of_mass "COM"

  @doc """
  iex> input = "COM)B,B)C,C)D,D)E,E)F,B)G,G)H,D)I,E)J,J)K,K)L"
  iex> AoC2019.Day6.orbit_checksum(String.split(input, ","))
  42
  """
  def orbit_checksum(input \\ AoC2019.stream(@day)) do
    input
    |> Stream.map(&String.split(&1, ")"))
    |> Enum.reduce(%{}, fn [a, b], map ->
      Map.update(map, a, [b], &[b | &1])
    end)
    |> count_orbits(@center_of_mass, 0)
  end

  defp count_orbits(map, object, depth) do
    orbits =
      map
      |> Map.get(object, [])
      |> Enum.reduce(0, fn object, acc ->
        acc + depth + count_orbits(map, object, depth + 1)
      end)

    orbits + if object != @center_of_mass, do: 1, else: 0
  end
end
