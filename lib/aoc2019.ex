defmodule AoC2019 do
  @path "priv/inputs"

  def input(day) when day in 1..25 do
    @path
    |> Path.join("day#{day}.txt")
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
