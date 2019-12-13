defmodule AoC2019.Day13 do
  @day 13

  @empty 0
  @wall 1
  @block 2
  @paddle 3
  @ball 4

  @doc """
  iex> AoC2019.Day13.play()
  12779
  """
  def play(input \\ AoC2019.read(@day)) do
    input = String.replace_prefix(input, "1", "2")
    {:ok, pid} = IntcodeComputer.start_program(input, ask_for_input: true)

    acc = %{
      map: %{},
      ball: {0, 0},
      paddle: {0, 0}
    }

    Enum.reduce_while(Stream.iterate(pid, & &1), acc, fn pid, acc ->
      case IntcodeComputer.get_output(pid) do
        :done ->
          {:halt, acc}

        :waiting_for_input ->
          move_paddle(pid, acc)
          {:cont, acc}

        x ->
          y = IntcodeComputer.get_output(pid)
          tile = IntcodeComputer.get_output(pid)
          {:cont, update(acc, x, y, tile)}
      end
    end)
    |> get_in([:map, :score])
  end

  defp update(%{map: map} = acc, x, y, @ball) do
    %{acc | map: update(map, x, y, @ball), ball: {x, y}}
  end

  defp update(%{map: map} = acc, x, y, @paddle) do
    %{acc | map: update(map, x, y, @paddle), paddle: {x, y}}
  end

  defp update(%{map: map} = acc, x, y, tile) do
    %{acc | map: update(map, x, y, tile)}
  end

  defp update(map, -1, 0, score), do: Map.put(map, :score, score)
  defp update(map, x, y, tile), do: Map.put(map, {x, y}, tile(tile))

  defp tile(@empty), do: " "
  defp tile(@wall), do: "|"
  defp tile(@block), do: "□"
  defp tile(@paddle), do: "_"
  defp tile(@ball), do: "o"

  defp move_paddle(pid, %{ball: {bx, _}, paddle: {px, _}}) do
    cond do
      bx < px -> IntcodeComputer.send_input(pid, -1)
      bx > px -> IntcodeComputer.send_input(pid, 1)
      true -> IntcodeComputer.send_input(pid, 0)
    end
  end
end
