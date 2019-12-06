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
    |> build_orbiting_objects()
    |> count_orbits(@center_of_mass, 0)
  end

  @doc !"""
  Builds map where values are objects orbiting key.
  """
  defp build_orbiting_objects(orbits) do
    orbits
    |> Stream.map(&String.split(&1, ")"))
    |> Enum.reduce(%{}, fn [a, b], orbiting_objects ->
      Map.update(orbiting_objects, a, [b], &[b | &1])
    end)
  end

  @doc !"""
  Builds map where value is object that key orbits.
  """
  defp build_orbited_objects(orbiting_objects) do
    Enum.reduce(orbiting_objects, %{}, fn {key, values}, orbited_objects ->
      Enum.reduce(values, orbited_objects, fn value, orbited_objects ->
        Map.put(orbited_objects, value, key)
      end)
    end)
  end

  defp count_orbits(orbiting_objects, object, depth) do
    orbits =
      orbiting_objects
      |> Map.get(object, [])
      |> Enum.reduce(0, fn object, acc ->
        acc + depth + count_orbits(orbiting_objects, object, depth + 1)
      end)

    orbits + if object != @center_of_mass, do: 1, else: 0
  end

  @doc """
  iex> input = "COM)B,B)C,C)D,D)E,E)F,B)G,G)H,D)I,E)J,J)K,K)L,K)YOU,I)SAN"
  iex> AoC2019.Day6.count_orbital_transfers(String.split(input, ","))
  4
  """
  def count_orbital_transfers(input \\ AoC2019.stream(@day), from \\ "YOU", to \\ "SAN") do
    orbiting_objects = build_orbiting_objects(input)
    orbited_objects = build_orbited_objects(orbiting_objects)

    do_count_orbital_transfers(orbiting_objects, orbited_objects, from, to, 0, [])
    |> elem(0)
    |> Enum.sort()
    |> hd()
  end

  defp do_count_orbital_transfers(_, _, from, from, count, visited) do
    {[count - 2], visited}
  end

  defp do_count_orbital_transfers(orbiting_objects, orbited_objects, from, to, count, visited) do
    to_visit = neighbours_objects(orbiting_objects, orbited_objects, from) -- visited

    Enum.flat_map_reduce(to_visit, visited, fn from, visited ->
      do_count_orbital_transfers(orbiting_objects, orbited_objects, from, to, count + 1, [from | visited])
    end)
  end

  defp neighbours_objects(orbiting_objects, orbited_objects, object) do
    [Map.get(orbited_objects, object) | Map.get(orbiting_objects, object, [])]
  end
end
