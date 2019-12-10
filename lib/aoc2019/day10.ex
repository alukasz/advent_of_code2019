defmodule AoC2019.Day10 do
  @day 10

  @doc """
  iex> AoC2019.Day10.most_visible_asteroids(".#..#\\n.....\\n#####\\n....#\\n...##")
  {{3, 4}, 8}
  iex> input = "......#.#.\\n#..#.#....\\n..#######.\\n.#.#.###..\\n.#..#.....\\n..#....#.#\\n#..#....#.\\n.##.#..###\\n##...#..#.\\n.#....####\\n"
  iex> AoC2019.Day10.most_visible_asteroids(input)
  {{5, 8}, 33}
  """
  def most_visible_asteroids(input \\ AoC2019.read(@day)) do
    map = input |> build_map()
    lookup_vectors = lookup_vectors(map)

    Enum.map(map, fn
      {location, :empty} ->
        {location, 0}

      {location, :asteroid} ->
        {location, length(visible_asteroids(map, lookup_vectors, location))}
    end)
    |> Enum.max_by(fn {_, x} -> x end)
  end

  defp visible_asteroids(map, lookup_vectors, location) do
    Enum.reduce(lookup_vectors, [], fn vector, visible_asteroids ->
      case first_in_vector(map, location, vector) do
        nil -> visible_asteroids
        location -> [location | visible_asteroids]
      end
    end)
  end

  defp first_in_vector(map, {lx, ly} = location, {dx, dy} = vector, m \\ 1) do
    location_to_check = {dx * m + lx, dy * m + ly}

    case Map.get(map, location_to_check) do
      :empty -> first_in_vector(map, location, vector, m + 1)
      :asteroid -> location_to_check
      nil -> nil
    end
  end

  def test do
    input =
      ".#....#####...#..\n##...##.#####..##\n##...#...#.#####.\n..#.........###..\n..#.#...#.#....##\n"

    vaporize_asteroids({8, 3}, input)
  end

  def test2 do
    vaporize_asteroids({11, 13}, large_input())
  end

  @doc """
  iex> AoC2019.Day10.vaporize_asteroids({11, 13}, AoC2019.Day10.large_input())
  {8, 2}
  iex> AoC2019.Day10.vaporize_asteroids()
  {15, 13}
  """
  def vaporize_asteroids({lx, ly} = laser_location \\ {27, 19}, input \\ AoC2019.read(@day)) do
    map = input |> build_map() |> Map.put(laser_location, :empty)
    lookup_vectors = lookup_vectors(map)

    first_up =
      visible_asteroids(map, lookup_vectors, laser_location)
      |> Enum.filter(&match?({^lx, y} when y < ly, &1))
      |> Enum.max_by(&elem(&1, 1))

    map = Map.put(map, first_up, :empty)

    Enum.reduce(2..200, {map, first_up}, fn _, {map, last} ->
      visible_asteroids = visible_asteroids(map, lookup_vectors, laser_location)

      [last_with_angle | locations_with_angles] =
        Enum.map([last | visible_asteroids], fn {ax, ay} = location ->
          dx = ax - lx
          dy = ly - ay
          angle = :math.atan2(dx, dy) * 180 / :math.pi()

          {location, if(angle >= 0, do: angle, else: 360 + angle)}
        end)

      last_angle = elem(last_with_angle, 1)

      {location, _angle} =
        Enum.filter(locations_with_angles, &(elem(&1, 1) > last_angle))
        |> sort_by_angle()
        |> case do
          [{location, angle} | _] ->
            {location, angle}

          [] ->
            Enum.filter(locations_with_angles, &(elem(&1, 1) >= 0))
            |> sort_by_angle()
            |> hd()
        end

      {Map.put(map, location, :empty), location}
    end)
    |> elem(1)
  end

  defp sort_by_angle(angles) do
    Enum.sort(angles, fn {{_, _}, a1}, {{_, _}, a2} -> a1 < a2 end)
  end

  defp build_map(input) do
    split =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        row
        |> String.split("", trim: true)
        |> Enum.map(fn
          "." -> :empty
          "#" -> :asteroid
        end)
        |> Enum.with_index()
      end)
      |> Enum.with_index()

    for {row, y} <- split, {cell, x} <- row, reduce: %{} do
      acc -> Map.put(acc, {x, y}, cell)
    end
  end

  defp lookup_vectors(map) do
    {{max_x, _}, _} = Enum.max_by(map, fn {{x, _}, _} -> x end)
    {{_, max_y}, _} = Enum.max_by(map, fn {{_, y}, _} -> y end)

    vectors =
      for x <- 0..max_x, y <- 0..max_y, reduce: [] do
        acc -> [{x, y}, {x, -y}, {-x, y}, {-y, -x} | acc]
      end
      |> Enum.into(MapSet.new())
      |> MapSet.delete({0, 0})

    max = max(max_x, max_y)

    Enum.reduce(vectors, vectors, fn {x, y}, vectors ->
      for i <- 2..max, reduce: vectors do
        vectors -> MapSet.delete(vectors, {x * i, y * i})
      end
    end)
    |> Enum.to_list()
  end

  def large_input do
    """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """
  end
end
