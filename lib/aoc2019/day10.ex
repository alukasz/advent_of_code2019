defmodule AoC2019.Day10 do
  @day 10

  @doc """
  iex> AoC2019.Day10.most_asteroids_visible(".#..#\\n.....\\n#####\\n....#\\n...##")
  {{3, 4}, 8}
  iex> input = "......#.#.\\n#..#.#....\\n..#######.\\n.#.#.###..\\n.#..#.....\\n..#....#.#\\n#..#....#.\\n.##.#..###\\n##...#..#.\\n.#....####\\n"
  iex> AoC2019.Day10.most_asteroids_visible(input)
  {{5, 8}, 33}
  """
  def most_asteroids_visible(input \\ AoC2019.read(@day)) do
    map = input |> build_map()
    lookup_vectors = lookup_vectors(map)

    Enum.map(map, fn
      {location, :empty} -> {location, 0}
      {location, :asteroid} -> {location, asteroids_visible(map, lookup_vectors, location)}
    end)
    |> Enum.max_by(fn {_, x} -> x end)
  end

  def asteroids_visible(map, lookup_vectors, location) do
    Enum.reduce(lookup_vectors, 0, fn vector, count ->
      count + count_in_vector(map, location, vector)
    end)
  end

  def count_in_vector(map, {lx, ly} = location, {dx, dy} = vector, count \\ 0, m \\ 1) do
    location_to_check = {dx * m + lx, dy * m + ly}

    case Map.get(map, location_to_check) do
      :empty -> count_in_vector(map, location, vector, count, m + 1)
      :asteroid -> 1
      nil -> count
    end
  end

  def build_map(input) do
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

  def lookup_vectors(map) do
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
end
