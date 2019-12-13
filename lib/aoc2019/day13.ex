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

    %{
      computer: pid,
      screen: %{},
      score: 0,
      ball: {0, 0},
      paddle: {0, 0}
    }
    |> do_play()
    |> Map.get(:score)
  end

  defp do_play(%{computer: pid} = state) do
    case IntcodeComputer.get_output(pid) do
      :done ->
        state

      :waiting_for_input ->
        move_paddle(state)
        do_play(state)

      x ->
        y = IntcodeComputer.get_output(pid)
        tile = IntcodeComputer.get_output(pid)
        do_play(update(state, x, y, tile))
    end
  end

  defp update(state, -1, 0, score) do
    %{state | score: score}
  end

  defp update(%{screen: screen} = state, x, y, @ball) do
    %{state | screen: update_screen(screen, x, y, @ball), ball: {x, y}}
  end

  defp update(%{screen: screen} = state, x, y, @paddle) do
    %{state | screen: update_screen(screen, x, y, @paddle), paddle: {x, y}}
  end

  defp update(%{screen: screen} = state, x, y, tile) do
    %{state | screen: update_screen(screen, x, y, tile)}
  end

  defp update_screen(screen, x, y, tile), do: Map.put(screen, {x, y}, tile(tile))

  defp tile(@empty), do: " "
  defp tile(@wall), do: "|"
  defp tile(@block), do: "□"
  defp tile(@paddle), do: "_"
  defp tile(@ball), do: "o"

  defp move_paddle(%{computer: pid, ball: {bx, _}, paddle: {px, _}}) do
    cond do
      bx < px -> IntcodeComputer.send_input(pid, -1)
      bx > px -> IntcodeComputer.send_input(pid, 1)
      true -> IntcodeComputer.send_input(pid, 0)
    end
  end
end
