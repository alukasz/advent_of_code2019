defmodule IntcodeComputer do
  @add 1
  @multiply 2
  @input 3
  @output 4
  @jump_if_true 5
  @jump_if_false 6
  @less_than 7
  @equals 8
  @adjust_relative_base 9
  @finish 99

  @position_mode 0
  @immediate_mode 1
  @relative_base_mode 2

  def start_program(program, opts \\ [])

  def start_program(program, opts) when is_binary(program) do
    program
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> start_program(opts)
  end

  def start_program(program, opts) when is_list(program) do
    caller = self()

    Task.start(fn ->
      program
      |> build_memory()
      |> Map.put(:caller, Keyword.get(opts, :caller, caller))
      |> Map.put(:relative_base, 0)
      |> Map.put(:ask_for_input, Keyword.get(opts, :ask_for_input, false))
      |> perform()
    end)
  end

  defp build_memory(program) do
    program
    |> Enum.with_index()
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Enum.into(%{})
  end

  def send_input(pid, input) do
    send(pid, {:input, input})
  end

  def get_output(pid) do
    receive do
      {:output, ^pid, output} -> output
      {:waiting_for_input, ^pid} -> :waiting_for_input
      {:done, ^pid} -> :done
    after
      5_000 ->
        {:error, :timeout}
    end
  end

  def get_all_output(pid, acc \\ []) do
    receive do
      {:output, ^pid, output} -> get_all_output(pid, [output | acc])
      {:waiting_for_input, ^pid} -> get_all_output(pid, acc)
      {:done, ^pid} -> Enum.reverse(acc)
    after
      5_000 ->
        {:error, :timeout}
    end
  end

  def perform(memory, instruction_pointer \\ 0) do
    case perform_instruction(memory, instruction_pointer) do
      {:done, memory, _instruction_pointer} ->
        memory

      {:ok, memory, instruction_pointer} ->
        perform(memory, instruction_pointer)
    end
  end

  def perform_instruction(memory, instruction_pointer) do
    instruction = read_next_instruction(memory, instruction_pointer)

    case do_perform_instruction(memory, instruction) do
      {status, memory} ->
        {status, memory, instruction_pointer + instruction_pointer_offset(instruction)}

      {_status, _memory_, _instruction_pointer} = result ->
        result
    end
  end

  def read_next_instruction(memory, instruction_pointer) do
    instruction = Map.get(memory, instruction_pointer)
    {opcode, param_modes} = parse_instruction(instruction)

    params =
      for i <- 1..instruction_params_count(opcode) do
        Map.get(memory, instruction_pointer + i)
      end

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
  defp instruction_params_count(@adjust_relative_base), do: 1
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
    if Map.get(memory, :ask_for_input) do
      send(Map.get(memory, :caller), {:waiting_for_input, self()})
    end

    receive do
      {:input, input} -> {:ok, set_memory(memory, param, input)}
    end
  end

  defp do_perform_instruction(memory, {@output, [param]}) do
    send(Map.get(memory, :caller), {:output, self(), get_memory(memory, param)})

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

  defp do_perform_instruction(memory, {@adjust_relative_base, [param]}) do
    {:ok, Map.update!(memory, :relative_base, &(&1 + get_memory(memory, param)))}
  end

  defp do_perform_instruction(memory, {@finish, _}) do
    send(Map.get(memory, :caller), {:done, self()})
    {:done, memory}
  end

  defp get_memory(_memory, {@immediate_mode, value}), do: value
  defp get_memory(memory, {@position_mode, pos}), do: Map.get(memory, pos, 0)

  defp get_memory(memory, {@relative_base_mode, pos}),
    do: Map.get(memory, pos + Map.get(memory, :relative_base), 0)

  defp set_memory(memory, {@position_mode, pos}, value), do: Map.put(memory, pos, value)

  defp set_memory(memory, {@relative_base_mode, pos}, value),
    do: Map.put(memory, pos + Map.get(memory, :relative_base), value)
end
