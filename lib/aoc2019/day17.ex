defmodule AoC2019.Day17 do
  @day 17

  @y_offset 39
  @scaffold ?#
  @empty ?.
  @vectors [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  @subroutines [?A, ?B, ?C]
  @north :north
  @south :south
  @west :west
  @east :east

  @doc """
  iex> AoC2019.Day17.sum_alignment_parameters_of_intersections()
  6212
  """
  def sum_alignment_parameters_of_intersections(input \\ AoC2019.read(@day)) do
    {:ok, pid} = IntcodeComputer.start_program(input)

    pid
    |> IntcodeComputer.get_all_output()
    |> build_map()
    |> find_intersections()
    |> compute_alignment_parameters()
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
    |> Enum.reduce({%{}, @y_offset}, fn line, {map, y} ->
      {map, _x} =
        Enum.reduce(line, {map, 0}, fn elem, {map, x} ->
          {Map.put(map, {x, y}, elem), x + 1}
        end)

      {map, y - 1}
    end)
    |> elem(0)
  end

  defp find_intersections(map) do
    Enum.reduce(map, [], fn
      {point, @scaffold}, acc ->
        if intersection?(map, point), do: [point | acc], else: acc

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
    Enum.map(points, fn {x, y} -> x * (@y_offset - y) end)
  end

  @doc """
  iex> AoC2019.Day17.notify_robots()
  1016741
  """
  def notify_robots(input \\ AoC2019.read(@day)) do
    input = String.replace_prefix(input, "1", "2")
    {:ok, pid} = IntcodeComputer.start_program(input)
    output = receive_until(pid, "Main:\n")

    subroutines =
      output
      |> build_map()
      |> build_path()
      |> Enum.map(fn
        {:left, length} -> {?L, length}
        {:right, length} -> {?R, length}
      end)
      |> subroutines([])
      |> hd()

    unique = Enum.group_by(subroutines, & &1) |> Map.keys()
    by_subroutine = Enum.zip(unique, @subroutines) |> Enum.into(%{})

    by_name =
      Enum.zip(@subroutines, unique)
      |> Enum.map(fn {name, subroutine} ->
        subroutine =
          Enum.flat_map(subroutine, fn
            {dir, 8} -> [dir, ?8]
            {dir, 10} -> [dir, [?1, ?0]]
            {dir, 12} -> [dir, [?1, ?2]]
          end)

        {name, subroutine}
      end)
      |> Enum.into(%{})

    main_routine =
      Enum.map(subroutines, fn subroutine ->
        Map.get(by_subroutine, subroutine)
      end)

    send_command(pid, main_routine)

    receive_until(pid, "A:\n")
    send_command(pid, by_name[?A])

    receive_until(pid, "B:\n")
    send_command(pid, by_name[?B])

    receive_until(pid, "C:\n")
    send_command(pid, by_name[?C])

    receive_until(pid, "feed?\n")
    send_command(pid, [?n])

    IntcodeComputer.get_all_output(pid) |> List.last()
  end

  defp build_path(map) do
    {robot_pos, ?^} = Enum.find(map, &match?({_, ?^}, &1))
    build_path(map, robot_pos, @north, 0, [:north])
  end

  defp build_path(map, robot_pos, direction, length, [last_turn | rest] = path) do
    new_pos = advance(robot_pos, direction)

    case Map.get(map, new_pos, @empty) do
      @scaffold ->
        build_path(map, new_pos, direction, length + 1, path)

      @empty ->
        case chose_new_direction(map, robot_pos, direction) do
          {new_direction, turn} ->
            build_path(map, robot_pos, new_direction, 0, [turn, {last_turn, length} | rest])

          :done ->
            [{last_turn, length} | rest]
            |> Enum.reverse()
            |> tl()
        end
    end
  end

  defp chose_new_direction(map, robot_pos, direction) do
    with {_, _, @empty} <- lookahead(map, robot_pos, direction, :left),
         {_, _, @empty} <- lookahead(map, robot_pos, direction, :right) do
      :done
    else
      {new_direction, turn, _} -> {new_direction, turn}
    end
  end

  defp lookahead(map, robot_pos, direction, turn) do
    new_direction = apply(__MODULE__, turn, [direction])
    new_pos = advance(robot_pos, new_direction)
    {new_direction, turn, Map.get(map, new_pos, @empty)}
  end

  defp advance({x, y}, @north), do: {x, y + 1}
  defp advance({x, y}, @south), do: {x, y - 1}
  defp advance({x, y}, @east), do: {x + 1, y}
  defp advance({x, y}, @west), do: {x - 1, y}

  def right(@north), do: @east
  def right(@south), do: @west
  def right(@east), do: @south
  def right(@west), do: @north

  def left(@north), do: @west
  def left(@south), do: @east
  def left(@east), do: @north
  def left(@west), do: @south

  defp subroutines([], acc) do
    unique_subroutines = acc |> Enum.uniq() |> length()
    if unique_subroutines > 3, do: [], else: [Enum.reverse(acc)]
  end

  defp subroutines(path, acc) do
    if acc |> Enum.uniq() |> length() > 3 do
      []
    else
      Enum.flat_map(2..4, fn length ->
        {subroutine, rest} = Enum.split(path, length)
        subroutines(rest, [subroutine | acc])
      end)
    end
  end

  defp receive_until(pid, until) do
    until = Enum.reverse(to_charlist(until))
    receive_until(pid, until, [])
  end

  defp receive_until(pid, until, acc) do
    output = IntcodeComputer.get_output(pid)
    acc = [output | acc]

    if List.starts_with?(acc, until) do
      Enum.reverse(acc)
    else
      receive_until(pid, until, acc)
    end
  end

  defp send_command(pid, subroutine) do
    subroutine
    |> Enum.intersperse(?,)
    |> List.flatten()
    |> Enum.each(fn x -> IntcodeComputer.send_input(pid, x) end)

    IntcodeComputer.send_input(pid, ?\n)
  end
end
