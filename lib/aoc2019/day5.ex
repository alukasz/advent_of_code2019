defmodule AoC2019.Day5 do
  @day 5

  @input_value 1

  def test_diagnostic(program \\ AoC2019.read(@day)) do
    program
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> perform()
  end

  @add 1
  @multiply 2
  @input 3
  @output 4
  @finish 99

  @position_mode 0
  @immediate_mode 1

  def perform(memory, instruction_pointer \\ 0) do
    instruction = read_next_instruction(Enum.drop(memory, instruction_pointer))

    case perform_instruction(memory, instruction) do
      {:done, memory} ->
        memory

      {:ok, memory} ->
        perform(memory, instruction_pointer + instruction_pointer_offset(instruction))
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
  iex> AoC2019.Day5.parse_instruction(3)
  {3, [0, 0, 0]}
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
  defp instruction_params_count(@finish), do: 0

  defp instruction_pointer_offset({opcode, _}) do
    instruction_params_count(opcode) + 1
  end

  def perform_instruction(memory, {@add, params}) do
    param1 = get_memory(memory, Enum.at(params, 0))
    param2 = get_memory(memory, Enum.at(params, 1))

    {:ok, set_memory(memory, Enum.at(params, 2), param1 + param2)}
  end

  def perform_instruction(memory, {@multiply, params}) do
    param1 = get_memory(memory, Enum.at(params, 0))
    param2 = get_memory(memory, Enum.at(params, 1))

    {:ok, set_memory(memory, Enum.at(params, 2), param1 * param2)}
  end

  def perform_instruction(memory, {@input, params}) do
    {:ok, set_memory(memory, Enum.at(params, 0), @input_value)}
  end

  def perform_instruction(memory, {@output, params}) do
    IO.inspect({:output, get_memory(memory, Enum.at(params, 0))})

    Inspect.Opts
    {:ok, memory}
  end

  def perform_instruction(memory, {@finish, _}) do
    {:done, memory}
  end

  defp get_memory(_memory, {@immediate_mode, value}), do: value
  defp get_memory(memory, {@position_mode, pos}), do: Enum.at(memory, pos)

  defp set_memory(memory, {@position_mode, pos}, value), do: List.replace_at(memory, pos, value)
end
