defmodule AoC2019.Day15 do
  @day 15
  @wall 0
  @moved 1
  @found 2

  @north {0, 1}
  @south {0, -1}
  @west {-1, 0}
  @east {1, 0}

  defmodule Robot do
    defstruct [:computer, direction: {0, 1}, map: %{{0, 0} => 1}, path: [{0, 0}]]
  end

  @doc """
  iex> AoC2019.Day15.fill_with_oxygen()
  326
  """
  def fill_with_oxygen(input \\ AoC2019.read(@day)) do
    {:ok, pid} = IntcodeComputer.start_program(input)
    {:ok, %{map: map}} = move(%Robot{computer: pid})

    Enum.reduce_while(Stream.iterate(0, &(&1 + 1)), map, fn time, map ->
      oxygen_fields = Enum.filter(map, &match?({_, @found}, &1))

      find_neighbour_fields(map, oxygen_fields)
      |> Enum.filter(&match?({_, @moved}, &1))
      |> case do
        [] ->
          {:halt, time}

        fields_to_expand ->
          map =
            Enum.reduce(fields_to_expand, map, fn {field, _}, map ->
              Map.put(map, field, @found)
            end)

          {:cont, map}
      end
    end)
  end

  defp find_neighbour_fields(map, fields) do
    neighbour_fields =
      fields
      |> Enum.flat_map(fn {field, _value} ->
        Enum.map(directions(), &advance(field, &1))
      end)
      |> Enum.uniq()

    Map.take(map, neighbour_fields)
  end

  def move(%{path: [_, _], map: map} = robot) when map_size(map) > 3 do
    {:ok, robot}
  end

  def move(robot) do
    {reply, robot} = do_move(robot)
    robot |> apply_move(reply) |> change_direction()
  end

  defp do_move(robot) do
    %{computer: pid, direction: direction} = robot
    IntcodeComputer.send_input(pid, robot_input(direction))
    reply = IntcodeComputer.get_output(pid)
    {reply, robot}
  end

  defp change_direction(robot) do
    %{map: map} = robot

    candidates =
      Enum.filter(directions(), fn direction ->
        location = advance(current_location(robot), direction)
        is_nil(Map.get(map, location))
      end)

    case candidates do
      [direction | _] -> move(%{robot | direction: direction})
      [] -> backtrack(robot)
    end
  end

  defp backtrack(robot) do
    %{path: path} = robot
    {@moved, robot} = do_move(%{robot | path: tl(path), direction: backtrack_direction(path)})
    change_direction(robot)
  end

  defp apply_move(robot, @wall) do
    %{direction: direction, map: map} = robot
    new_location = advance(current_location(robot), direction)
    %{robot | map: Map.put(map, new_location, @wall)}
  end

  defp apply_move(robot, reply) do
    %{direction: direction, map: map, path: path} = robot
    new_location = advance(current_location(robot), direction)
    map = Map.put(map, new_location, reply)
    %{robot | path: [new_location | path], map: map}
  end

  defp current_location(%{path: [location | _]}), do: location

  defp advance({x, y}, {dx, dy}), do: {x + dx, y + dy}

  defp directions do
    [@north, @south, @west, @east]
  end

  # defp backtrack_direction([{_, _}]), do: {0, 1}
  defp backtrack_direction([{x1, y1}, {x2, y2} | _]), do: {x2 - x1, y2 - y1}

  defp robot_input(@north), do: 1
  defp robot_input(@south), do: 2
  defp robot_input(@west), do: 3
  defp robot_input(@east), do: 4
end
