defmodule AoC2019.Day2 do
  @day 2
  @part2_output 19_690_720
  @noun_pointer 1
  @verb_pointer 2

  def intcode_computer do
    input =
      AoC2019.read(@day)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    program =
      Enum.zip(0..1_000_000, input)
      |> Enum.into(%{})

    {noun, verb} =
      Enum.reduce_while(0..99, nil, fn noun, _ ->
        Enum.reduce_while(0..99, nil, fn verb, _ ->
          program
          |> Map.put(@noun_pointer, noun)
          |> Map.put(@verb_pointer, verb)
          |> perform()
          |> case do
            %{0 => @part2_output} -> {:halt, {:halt, {noun, verb}}}
            _ -> {:cont, {:cont, {nil, nil}}}
          end
        end)
      end)

    noun * 100 + verb
  end

  @instrucion_offset 4
  @add 1
  @multiply 2
  @finish 99

  @doc """
  iex> AoC2019.Day2.perform(%{0 => 1, 1 => 1, 2 => 1, 3 => 4, 4 => 99, 5 => 5, 6 => 6, 7 => 0, 8 => 99})
  %{0 => 30, 1 => 1, 2 => 1, 3 => 4, 4 => 2, 5 => 5, 6 => 6, 7 => 0, 8 => 99}
  """
  def perform(memory, instruction_pointer \\ 0) do
    case operation(instruction(memory, instruction_pointer)) do
      :done -> memory
      operation -> perform(operation.(memory), instruction_pointer + @instrucion_offset)
    end
  end

  defp instruction(memory, instruction_pointer) do
    {
      Map.get(memory, instruction_pointer),
      Map.get(memory, instruction_pointer + 1),
      Map.get(memory, instruction_pointer + 2),
      Map.get(memory, instruction_pointer + 3)
    }
  end

  defp operation({@finish, _, _, _}), do: :done

  defp operation({@add, param1, param2, param3}) do
    operation_fun(&Kernel.+/2, param1, param2, param3)
  end

  defp operation({@multiply, param1, param2, param3}) do
    operation_fun(&Kernel.*/2, param1, param2, param3)
  end

  defp operation_fun(operation, param1, param2, param3) do
    fn memory ->
      result = operation.(Map.get(memory, param1), Map.get(memory, param2))
      Map.put(memory, param3, result)
    end
  end
end
