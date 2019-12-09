defmodule AoC2019.Day9 do
  @day 9

  alias AoC2019.Day5, as: IntcodeComputer

  @doc """
  iex> AoC2019.Day9.test("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
  :ok
  iex> [number] = AoC2019.Day9.test("1102,34915192,34915192,7,4,7,99,0")
  iex> length(Integer.digits(number))
  16
  iex> AoC2019.Day9.test("104,1125899906842624,99")
  [1125899906842624]
  iex> AoC2019.Day9.test()
  [3507134798]
  """
  def test(input \\ AoC2019.read(@day)) do
    program =
      input
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)

    {:ok, pid} = IntcodeComputer.start_intcode_program(program)
    IntcodeComputer.send_input(pid, 1)
    IntcodeComputer.get_output(pid)
  end
end
