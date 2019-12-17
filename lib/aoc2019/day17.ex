defmodule AoC2019.Day17 do
  @day 17

  @doc """
  iex> AoC2019.Day17.sum_alignment_parameters_of_intersections()
  6212
  """
  def sum_alignment_parameters_of_intersections(input \\ AoC2019.read(@day)) do
    {:ok, pid} = IntcodeComputer.start_program(input)

    pid
    |> IntcodeComputer.get_all_output()
    |> build_map()
    |> find_intersections
    |> compute_alignment_parameters
    |> Enum.sum()
  end

  defp build_map(output) do
    Enum.chunk_while(
      output,
      [],
      fn
        ?\n, [_ | _] = acc -> {:cont, Enum.reverse(acc), []}
        ?\n, [] -> {:cont, []}
        elem, acc -> {:cont, [elem | acc]}
      end,
      fn
        [] -> {:cont, []}
        acc -> {:cont, Enum.reverse(acc), []}
      end
    )
    |> Enum.reduce({%{}, 0}, fn line, {map, y} ->
      {map, _x} =
        Enum.reduce(line, {map, 0}, fn elem, {map, x} ->
          {Map.put(map, {x, y}, elem), x + 1}
        end)

      {map, y + 1}
    end)
    |> elem(0)
  end

  defp draw_map(map) do
    for y <- 0..40 do
      for x <- 0..48 do
        Map.get(map, {x, y}, 0)
      end
    end
    |> Enum.intersperse(?\n)
    |> IO.puts()
  end

  @scaffold ?#

  @vectors [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  defp find_intersections(map) do
    Enum.reduce(map, [], fn
      {point, @scaffold}, acc ->
        case intersection?(map, point) do
          true -> [point | acc]
          false -> acc
        end

      _, acc ->
        acc
    end)
  end

  defp intersection?(map, {x, y}) do
    @vectors
    |> Enum.map(fn {dx, dy} ->
      Map.get(map, {x + dx, y + dy})
    end)
    |> Enum.all?(&match?(@scaffold, &1))
  end

  defp compute_alignment_parameters(points) do
    Enum.map(points, fn {x, y} -> x * y end)
  end
end
