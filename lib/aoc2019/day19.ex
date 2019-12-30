defmodule AoC2019.Day19 do
  @day 19

  @pulled 1

  @doc """
  iex> AoC2019.Day19.tractor_beam_area()
  169
  """
  def tractor_beam_area(input \\ AoC2019.read(@day)) do
    input =
      input
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    for x <- 0..49, y <- 0..49 do
      in_beam?(input, {x, y})
    end
    |> Enum.count(& &1)
  end

  def distance_to_ship(input \\ AoC2019.read(@day)) do
    input =
      input
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    Enum.reduce_while(Stream.iterate(1100, & &1 + 1), nil, fn y, nil ->
      IO.puts y
      compute_row(input, y)
      |> Enum.filter(&match?({_, true, true}, &1))
      |> case do
          [] -> {:cont, nil}
          [solution | _] -> {:halt, solution}
      end
    end)
  end

  def compute_row(input, y) do
    for x <- 0..y do
      {{x, y}, in_beam?(input, {x, y})}
    end
    |> Enum.filter(&match?({_, true}, &1))
    |> Enum.map(fn {{x, y}, true} ->
      {{x, y}, in_beam?(input, {x + 99, y}), in_beam?(input, {x, y + 99})}
    end)
  end

  defp in_beam?(input, {x, y}) do
    {:ok, pid} = IntcodeComputer.start_program(input)
    IntcodeComputer.send_input(pid, x)
    IntcodeComputer.send_input(pid, y)
    @pulled == IntcodeComputer.get_output(pid)
  end
end
