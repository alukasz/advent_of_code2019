defmodule AoC2019.Day3 do
  @day 3
  @central_port {0, 0}
  @up {1, 0}
  @down {-1, 0}
  @right {0, 1}
  @left {0, -1}

  @doc """
  iex> first = "R75,D30,R83,U83,L12,D49,R71,U7,L72"
  iex> second = "U62,R66,U55,R34,D71,R55,D58,R83"
  iex> AoC2019.Day3.closest_intersection([first, second])
  610
  """
  def closest_intersection(paths \\ AoC2019.stream(@day)) do
    [wire1, wire2] =
      paths
      |> Enum.map(&parse_path/1)
      |> Enum.map(&draw_wire/1)

    intersections =
      MapSet.intersection(
        MapSet.new(Map.keys(wire1)),
        MapSet.new(Map.keys(wire2))
      )
      |> MapSet.delete(@central_port)

    intersections
    |> Enum.reduce([], fn intersection, acc ->
      distance = Map.get(wire1, intersection) + Map.get(wire2, intersection)
      [distance | acc]
    end)
    |> Enum.sort()
    |> hd()
  end

  @doc """
  iex> AoC2019.Day3.parse_path("R1,D2,L1,U3")
  [{0, 1}, {-1, 0}, {-1, 0}, {0, -1}, {1, 0}, {1, 0}, {1, 0}]
  """
  def parse_path(path) do
    path
    |> String.split(",", trim: true)
    |> Enum.flat_map(fn
      "U" <> distance -> List.duplicate(@up, String.to_integer(distance))
      "D" <> distance -> List.duplicate(@down, String.to_integer(distance))
      "R" <> distance -> List.duplicate(@right, String.to_integer(distance))
      "L" <> distance -> List.duplicate(@left, String.to_integer(distance))
    end)
  end

  @doc """
  iex> AoC2019.Day3.draw_wire([{0, 1}, {0, 1}])
  %{{0, 0} => 0, {0, 1} => 1, {0, 2} => 2}
  iex> AoC2019.Day3.draw_wire([{0, -1}, {0, -1}, {1, 0}])
  %{{0, 0} => 0, {0, -1} => 1, {0, -2} => 2, {1, -2} => 3}
  """
  def draw_wire(path) do
    {_, map} =
      path
      |> Enum.with_index(1)
      |> Enum.reduce({@central_port, %{@central_port => 0}}, &draw_wire_point/2)

    map
  end

  defp draw_wire_point({{ox, oy} = _offset, step}, {{x, y} = _last, grid}) do
    point = {x + ox, y + oy}
    {point, Map.put(grid, point, step)}
  end
end
