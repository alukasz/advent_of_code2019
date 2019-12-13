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
    {:ok, pid} = IntcodeComputer.start_program(program)
    IntcodeComputer.send_input(pid, input)
    IntcodeComputer.get_output(pid)
  end
end
