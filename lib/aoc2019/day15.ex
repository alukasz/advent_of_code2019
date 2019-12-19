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
  iex> AoC2019.Day15.shortest_path
  216
  """
  def shortest_path(input \\ AoC2019.read(@day)) do
    {:ok, pid} = IntcodeComputer.start_program(input)
    {:ok, robot} = move(%Robot{computer: pid})
    # draw_map(robot)
    length(robot.path) - 1
  end

  def move(robot) do
    {reply, robot} = do_move(robot)
    robot = apply_move(robot, reply)

    case reply do
      @wall -> robot |> change_direction() #|> move()
      @moved -> robot |> move()
      @found -> {:ok, robot}
    end
  end

  defp do_move(robot) do
    %{computer: pid, direction: direction} = robot
    IntcodeComputer.send_input(pid, robot_input(direction))
    reply = IntcodeComputer.get_output(pid)
    {reply, robot}
  end

  defp change_direction(robot) do
    %{map: map} = robot
    candidates = Enum.filter(directions(), fn direction ->
      location = advance(current_location(robot), direction)
      is_nil(Map.get(map, location))
    end) |> Enum.shuffle()

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

  defp directions, do: [@north, @south, @west, @east]

  defp backtrack_direction([{x1, y1}, {x2, y2} | _]) do
    {x2 - x1, y2 - y1}
  end

  defp robot_input(@north), do: 1
  defp robot_input(@south), do: 2
  defp robot_input(@west), do: 3
  defp robot_input(@east), do: 4

  defp draw_map(robot) do
    IO.puts("-------------------")
    %{map: map, path: [location | _], direction: direction} = robot
    {{min_x, _}, _} = Enum.min_by(map, fn {{x, _}, _} -> x end)
    {{_, min_y}, _} = Enum.min_by(map, fn {{_, y}, _} -> y end)
    {{max_x, _}, _} = Enum.max_by(map, fn {{x, _}, _} -> x end)
    {{_, max_y}, _} = Enum.max_by(map, fn {{_, y}, _} -> y end)

    for y <- max_y..min_y do
      for x <- min_x..max_x do
        cond do
          {x, y} == {0, 0} -> "%"
          {x, y} == location -> robot_indicator(direction)
          true -> tile(Map.get(map, {x, y}))
        end
      end
    end
    |> Enum.intersperse("\n")
    |> IO.puts()

    robot
  end

  defp robot_indicator(@north), do: "^"
  defp robot_indicator(@south), do: "v"
  defp robot_indicator(@east), do: ">"
  defp robot_indicator(@west), do: "<"

  defp tile(@wall), do: "#"
  defp tile(@moved), do: "."
  defp tile(@found), do: "*"
  defp tile(_), do: " "
end
