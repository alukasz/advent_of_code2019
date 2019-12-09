defmodule AoC2019.Day8 do
  @day 8
  @width 25
  @height 6

  def calculate_checksum(pixels \\ AoC2019.read(@day)) do
    layers =
      pixels
      |> String.split("", trim: true)
      |> Enum.chunk_every(@width)
      |> Enum.chunk_every(@height)

    layer_with_most_zeros =
      Enum.map(layers, fn layer ->
        layer
        |> List.flatten()
        |> Enum.group_by(& &1)
      end)
      |> Enum.min_by(&length(Map.get(&1, "0")))

    length(Map.get(layer_with_most_zeros, "1")) * length(Map.get(layer_with_most_zeros, "2"))
  end
end
