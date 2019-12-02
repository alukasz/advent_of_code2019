defmodule AoC2019.Day2 do
  @day 2
  @part2_output 19_690_720
  @noun_pointer 1
  @verb_pointer 2

  def intcode_computer do
    program =
      AoC2019.read(@day)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {noun, verb} =
      Enum.reduce_while(0..99, nil, fn noun, _ ->
        Enum.reduce_while(0..99, nil, fn verb, _ ->
          program
          |> List.replace_at(@noun_pointer, noun)
          |> List.replace_at(@verb_pointer, verb)
          |> perform()
          |> case do
            [@part2_output | _] -> {:halt, {:halt, {noun, verb}}}
            _ -> {:cont, {:cont, nil}}
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
  iex> AoC2019.Day2.perform([2,3,0,3,99])
  [2,3,0,6,99]
  iex> AoC2019.Day2.perform([1,1,1,4,99,5,6,0,99])
  [30,1,1,4,2,5,6,0,99]
  iex> AoC2019.Day2.perform([1,9,10,3,2,3,11,0,99,30,40,50])
  [3500,9,10,70,2,3,11,0,99,30,40,50]
  """
  def perform(program, instruction_pointer \\ 0) do
    case instrucion(Enum.drop(program, instruction_pointer)) do
      :done -> program
      instrucion -> perform(instrucion.(program), instruction_pointer + @instrucion_offset)
    end
  end

  defp instrucion([@finish | _]), do: :done

  defp instrucion([@add, param1, param2, param3 | _]) do
    instruction_fun(&Kernel.+/2, param1, param2, param3)
  end

  defp instrucion([@multiply, param1, param2, param3 | _]) do
    instruction_fun(&Kernel.*/2, param1, param2, param3)
  end

  defp instruction_fun(operation, param1, param2, param3) do
    fn program ->
      result = operation.(Enum.at(program, param1), Enum.at(program, param2))
      List.replace_at(program, param3, result)
    end
  end
end
