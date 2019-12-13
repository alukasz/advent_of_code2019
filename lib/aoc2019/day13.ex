defmodule AoC2019.Day13 do
  @day 13

  @empty 0
  @wall 1
  @block 2
  @horizontal_paddle 3
  @ball 4

  def play(input \\ AoC2019.read(@day)) do
    {:ok, pid} = IntcodeComputer.start_program(input)

    Enum.reduce_while(Stream.iterate(pid, & &1), %{}, fn pid, map ->
      case IntcodeComputer.get_output(pid) do
        :done ->
          {:halt, map}

        x ->
          y = IntcodeComputer.get_output(pid)
          tile = IntcodeComputer.get_output(pid)
          {:cont, update(map, x, y, tile)}
      end
    end)
  end

  defp update(map, x, y, tile), do: Map.put(map, {x, y}, tile(tile))

  defp tile(@empty), do: nil
  defp tile(@wall), do: "|"
  defp tile(@block), do: "□"
  defp tile(@horizontal_paddle), do: "-"
  defp tile(@ball), do: "o"
end
