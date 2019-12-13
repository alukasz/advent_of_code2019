defmodule AoC2019.Day7 do
  @day 7

  @first_input 0

  @doc """
  iex> AoC2019.Day7.max_thrusters_signal()
  19539216
  """
  def max_thrusters_signal(input \\ AoC2019.read(@day)) do
    program =
      input
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    phase_settings = permute(5..9)

    Enum.map(phase_settings, &amplifiers_output(program, &1))
    |> Enum.max()
  end

  @doc """
  iex> AoC2019.Day7.amplifiers_output([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5], [9,8,7,6,5])
  139629729
  iex> AoC2019.Day7.amplifiers_output([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10], [9,7,8,5,6])
  18216
  """
  def amplifiers_output(program, phase_settings) do
    pids =
      for _ <- 1..length(phase_settings) do
        {:ok, pid} = IntcodeComputer.start_program(program)
        pid
      end

    pids = pids |> Enum.zip([:a, :b, :c, :d, :e])

    Enum.reduce_while(Stream.cycle(pids), {@first_input, nil, phase_settings}, fn
      {pid, _}, {input, e_output, [phase_setting | rest]} ->
        IntcodeComputer.send_input(pid, phase_setting)
        IntcodeComputer.send_input(pid, input)

        case IntcodeComputer.get_output(pid) do
          :done -> {:halt, e_output}
          output -> {:cont, {output, e_output, rest}}
        end

      {pid, amplifier}, {input, e_output, []} ->
        IntcodeComputer.send_input(pid, input)


      case IntcodeComputer.get_output(pid) do
        :done ->
          {:halt, e_output}

        output ->
          {:cont, {output, if(amplifier == :e, do: output, else: e_output), []}}
      end
    end)
  end

  # from https://rosettacode.org/wiki/Permutations#Elixir
  defp permute(_.._ = range), do: permute(Enum.to_list(range))
  defp permute([]), do: [[]]

  defp permute(list) do
    for x <- list, y <- permute(list -- [x]), do: [x | y]
  end
end
