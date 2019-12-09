defmodule AoC2019.Day7 do
  @day 7

  alias AoC2019.Day5, as: IntcodeComputer

  @first_input 0

  def max_thrusters_signal(input \\ AoC2019.read(@day)) do
    program =
      input
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    phase_settings = permute(0..4)

    Enum.map(phase_settings, &amplifiers_output(program, &1))
    |> Enum.max()
  end

  @doc """
  iex> AoC2019.Day7.amplifiers_output([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0], [4,3,2,1,0])
  43210
  iex> AoC2019.Day7.amplifiers_output([3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0], [0,1,2,3,4])
  54321
  """
  def amplifiers_output(program, phase_settings) do
    Enum.reduce(phase_settings, @first_input, fn phase_setting, input ->
      {:ok, pid} = IntcodeComputer.start_intcode_program(program)
      IntcodeComputer.send_input(pid, phase_setting)
      IntcodeComputer.send_input(pid, input)
      IntcodeComputer.get_output() |> hd()
    end)
  end

  # from https://rosettacode.org/wiki/Permutations#Elixir
  defp permute(_.._ = range), do: permute(Enum.to_list(range))
  defp permute([]), do: [[]]

  defp permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end
end
