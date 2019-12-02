defmodule AoC2019.Day2 do
  @day 2

  def intcode_computer do
    AoC2019.read(@day)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> List.replace_at(1, 12)
    |> List.replace_at(2, 2)
    |> perform()
    |> Enum.at(0)
  end

  @operation_offset 4
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
  def perform(program, pos \\ 0) do
    case operation(Enum.drop(program, pos)) do
      :done -> program
      operation -> perform(operation.(program), pos + @operation_offset)
    end
  end

  defp operation([@finish | _]), do: :done

  defp operation([opcode, arg1_pos, arg2_pos, result_pos | _]) do
    fn program ->
      operation = opcode_operation(opcode)
      result = operation.(Enum.at(program, arg1_pos), Enum.at(program, arg2_pos))
      List.replace_at(program, result_pos, result)
    end
  end

  defp opcode_operation(@add), do: &Kernel.+/2
  defp opcode_operation(@multiply), do: &Kernel.*/2
end
