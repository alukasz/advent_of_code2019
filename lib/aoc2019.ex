defmodule AoC2019 do
  @path "priv/inputs"

  def stream(day) when day in 1..25 do
    day
    |> path()
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  def read(day) when day in 1..25 do
    day
    |> path
    |> File.read!()
    |> String.trim()
  end

  defp path(day) do
    Path.join(@path, "day#{day}.txt")
  end
end
