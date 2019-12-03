defmodule AoC2019.Day3 do
  @day 3

  @doc """
  iex> AoC2019.Day3.closest_intersection(["R75,D30,R83,U83,L12,D49,R71,U7,L72", "U62,R66,U55,R34,D71,R55,D58,R83"])
  159
  """
  def closest_intersection(paths \\ AoC2019.stream(@day)) do
    [wire1, wire2] =
      paths
      |> Enum.map(&parse_path/1)
      |> Enum.map(&draw_wire/1)

    wire1
    |> MapSet.intersection(wire2)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.sort()
    |> List.delete(0)
    |> hd()
  end

  @up {1, 0}
  @down {-1, 0}
  @right {0, 1}
  @left {0, -1}

  @doc """
  iex> AoC2019.Day3.parse_path("R75,D30,L83,U80")
  [{{0, 1}, 75}, {{-1, 0}, 30}, {{0, -1}, 83}, {{1, 0}, 80}]
  """
  def parse_path(path) do
    path
    |> String.split(",", trim: true)
    |> Enum.map(fn
      "U" <> distance -> {@up, String.to_integer(distance)}
      "D" <> distance -> {@down, String.to_integer(distance)}
      "R" <> distance -> {@right, String.to_integer(distance)}
      "L" <> distance -> {@left, String.to_integer(distance)}
    end)
  end

  @doc """
  iex> AoC2019.Day3.draw_wire([{{0, 1}, 2}])
  MapSet.new([{0, 0}, {0, 1}, {0, 2}])
  iex> AoC2019.Day3.draw_wire([{{0, -1}, 2}, {{1, 0}, 1}])
  MapSet.new([{0, 0}, {0, -1}, {0, -2}, {1, -2}])
  """
  def draw_wire(path) do
    {_, map} = Enum.reduce(path, {{0, 0}, MapSet.new([{0, 0}])}, &draw_wire_step/2)
    map
  end

  defp draw_wire_step({direction, distance}, {last, map}) do
    {_, last, map} = Enum.reduce(1..distance, {direction, last, map}, &draw_wire_point/2)
    {last, map}
  end

  defp draw_wire_point(_, {{ox, oy} = direction, {x, y} = _last, map}) do
    point = {x + ox, y + oy}
    {direction, point, MapSet.put(map, point)}
  end
end
