defmodule AoC2019.Day11 do
  alias AoC2019.Day5, as: IntcodeComputer

  @day 11
  @black 0
  @white 1
  @left 0
  @right 1

  @doc """
  iex> AoC2019.Day11.count_panels() do
  2268
  """
  def count_panels(input \\ AoC2019.read(@day)) do
    paint(input, @black) |> map_size()
  end

  def print_map(input \\ AoC2019.read(@day)) do
    map = paint(input, @white)
    {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(map, fn {{x, _y}, _color} -> x end)
    {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(map, fn {{_x, y}, _color} -> y end)
    IO.inspect(binding())

    for y <- max_y..min_y do
      for x <- min_x..max_x do
        case Map.get(map, {x, y}) do
          nil -> IO.write(" ")
          @black -> IO.write(" ")
          @white -> IO.write("#")
        end
      end
      IO.write("\n")
    end
  end

  defp paint(input, starting_color) do
    {:ok, pid} = IntcodeComputer.start_intcode_program(input)

    empty_colors =
      Stream.transform(Stream.cycle([1]), starting_color, fn
        _, @white -> {[@white], @black}
        _, @black -> {[@black], @black}
      end)

    {map, _, _} =
      Enum.reduce_while(empty_colors, {%{}, {0, 0}, :up}, fn empty_color, {map, loc, dir} ->
        color = Map.get(map, loc, empty_color)
        IntcodeComputer.send_input(pid, color)

        receive do
          {:output, ^pid, color_to_paint} ->
            receive do
              {:output, ^pid, turn} ->
                map = Map.put(map, loc, color_to_paint)
                {loc, dir} = move(dir, turn, loc)

                {:cont, {map, loc, dir}}

              {:done, ^pid} ->
                {:halt, {map, loc, dir}}
            end

          {:done, ^pid} ->
            {:halt, {map, loc, dir}}
        end
      end)

    map
  end

  defp move(:up, @left, {x, y}), do: {{x - 1, y}, :left}
  defp move(:up, @right, {x, y}), do: {{x + 1, y}, :right}

  defp move(:down, @left, {x, y}), do: {{x + 1, y}, :right}
  defp move(:down, @right, {x, y}), do: {{x - 1, y}, :left}

  defp move(:left, @left, {x, y}), do: {{x, y - 1}, :down}
  defp move(:left, @right, {x, y}), do: {{x, y + 1}, :up}

  defp move(:right, @left, {x, y}), do: {{x, y + 1}, :up}
  defp move(:right, @right, {x, y}), do: {{x, y - 1}, :down}
end
