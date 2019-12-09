defmodule AoC2019.Day5 do
  @day 5

  @doc """
  iex> program = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
  iex> AoC2019.Day5.test_diagnostic(program, 7)
  999
  iex> AoC2019.Day5.test_diagnostic(program, 8)
  1000
  iex> AoC2019.Day5.test_diagnostic(program, 9)
  1001
  """
  def test_diagnostic(program \\ AoC2019.read(@day), input) do
    program =
      program
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    {:ok, pid} = start_intcode_program(program)
    send_input(pid, input)
    get_output() |> hd
  end

  @add 1
  @multiply 2
  @input 3
  @output 4
  @jump_if_true 5
  @jump_if_false 6
  @less_than 7
  @equals 8
  @finish 99

  @position_mode 0
  @immediate_mode 1

  def start_intcode_program(program, caller \\ self()) do
    Task.start(fn ->
      Process.put(:caller, caller)
      perform(program)
    end)
  end

  def send_input(pid, input) do
    send(pid, {:input, input})
  end

  @doc """
  Output in reverse order - last output is first value.
  """
  def get_output(acc \\ []) do
    receive do
      {:output, output} -> get_output([output | acc])
      :done -> acc
    after
      5_000 ->
        {:error, :timeout}
    end
  end

  def perform(memory, instruction_pointer \\ 0) do
    case perform_instruction(memory, instruction_pointer) do
      {:done, memory, _instruction_pointer} ->
        send(Process.get(:caller), :done)
        memory

      {:ok, memory, instruction_pointer} ->
        perform(memory, instruction_pointer)
    end
  end

  def perform_instruction(memory, instruction_pointer) do
    instruction = read_next_instruction(Enum.drop(memory, instruction_pointer))

    case do_perform_instruction(memory, instruction) do
      {status, memory} ->
        {status, memory, instruction_pointer + instruction_pointer_offset(instruction)}

      {_status, _memory_, _instruction_pointer} = result ->
        result
    end
  end

  def read_next_instruction([instruction | rest]) do
    {opcode, param_modes} = parse_instruction(instruction)
    params = Enum.take(rest, instruction_params_count(opcode))
    {opcode, Enum.zip(param_modes, params)}
  end

  @doc """
  iex> AoC2019.Day5.parse_instruction(3)
  {3, [0, 0, 0]}
  iex> AoC2019.Day5.parse_instruction(1002)
  {2, [0, 1, 0]}
  iex> AoC2019.Day5.parse_instruction(1102)
  {2, [1, 1, 0]}
  iex> AoC2019.Day5.parse_instruction(99)
  {99, [0, 0, 0]}
  """
  def parse_instruction(instruction) do
    case Integer.digits(instruction) |> Enum.reverse() do
      [9, 9 | _] -> {@finish, parse_param_modes([])}
      [opcode, 0 | param_modes] -> {opcode, parse_param_modes(param_modes)}
      [opcode] -> {opcode, parse_param_modes([])}
    end
  end

  defp parse_param_modes([]), do: [@position_mode, @position_mode, @position_mode]
  defp parse_param_modes([mode1]), do: [mode1, @position_mode, @position_mode]
  defp parse_param_modes([mode1, mode2]), do: [mode1, mode2, @position_mode]
  defp parse_param_modes([_, _, _] = modes), do: modes

  defp instruction_params_count(@add), do: 3
  defp instruction_params_count(@multiply), do: 3
  defp instruction_params_count(@input), do: 1
  defp instruction_params_count(@output), do: 1
  defp instruction_params_count(@jump_if_true), do: 2
  defp instruction_params_count(@jump_if_false), do: 2
  defp instruction_params_count(@less_than), do: 3
  defp instruction_params_count(@equals), do: 3
  defp instruction_params_count(@finish), do: 0

  defp instruction_pointer_offset({opcode, _}) do
    instruction_params_count(opcode) + 1
  end

  defp do_perform_instruction(memory, {@add, [param1, param2, param3]}) do
    result = get_memory(memory, param1) + get_memory(memory, param2)
    {:ok, set_memory(memory, param3, result)}
  end

  defp do_perform_instruction(memory, {@multiply, [param1, param2, param3]}) do
    result = get_memory(memory, param1) * get_memory(memory, param2)
    {:ok, set_memory(memory, param3, result)}
  end

  defp do_perform_instruction(memory, {@input, [param]}) do
    # IO.puts "waiting for input"
    receive do
      {:input, input} -> {:ok, set_memory(memory, param, input)}
    end
  end

  defp do_perform_instruction(memory, {@output, [param]}) do
    # IO.inspect({:output, get_memory(memory, param)})
    send(Process.get(:caller), {:output, get_memory(memory, param)})

    {:ok, memory}
  end

  defp do_perform_instruction(memory, {@jump_if_true, [param1, param2]}) do
    case get_memory(memory, param1) do
      0 -> {:ok, memory}
      _ -> {:ok, memory, get_memory(memory, param2)}
    end
  end

  defp do_perform_instruction(memory, {@jump_if_false, [param1, param2]}) do
    case get_memory(memory, param1) do
      0 -> {:ok, memory, get_memory(memory, param2)}
      _ -> {:ok, memory}
    end
  end

  defp do_perform_instruction(memory, {@less_than, [param1, param2, param3]}) do
    case get_memory(memory, param1) < get_memory(memory, param2) do
      true -> {:ok, set_memory(memory, param3, 1)}
      _ -> {:ok, set_memory(memory, param3, 0)}
    end
  end

  defp do_perform_instruction(memory, {@equals, [param1, param2, param3]}) do
    case get_memory(memory, param1) == get_memory(memory, param2) do
      true -> {:ok, set_memory(memory, param3, 1)}
      _ -> {:ok, set_memory(memory, param3, 0)}
    end
  end

  defp do_perform_instruction(memory, {@finish, _}) do
    {:done, memory}
  end

  defp get_memory(_memory, {@immediate_mode, value}), do: value
  defp get_memory(memory, {@position_mode, pos}), do: Enum.at(memory, pos)

  defp set_memory(memory, {@position_mode, pos}, value), do: List.replace_at(memory, pos, value)
end
