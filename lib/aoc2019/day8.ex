defmodule AoC2019.Day8 do
  @day 8
  @width 25
  @height 6

  @black 0
  @white 1
  @transparent 2

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

  @doc """
  iex> AoC2019.Day8.decode_image "0222112222120000", 2, 2
  [0, 1, 1, 0]
  """
  def decode_image(pixels \\ AoC2019.read(@day), height \\ @height, width \\ @width) do
    pixels =
      pixels
      |> String.split("", trim: true)
      |> Enum.map(&String.to_integer/1)

    offset = height * width

    for i <- 0..(offset - 1) do
      Stream.transform(pixels, i, fn _, acc ->
        case acc < length(pixels) do
          true -> {[Enum.at(pixels, acc)], acc + offset}
          false -> {:halt, acc}
        end
      end)
      |> Enum.reduce_while(@transparent, fn
        @black, _ -> {:halt, @black}
        @white, _ -> {:halt, @white}
        @transparent, acc -> {:cont, acc}
      end)
    end
  end

  def print_image(pixels) do
    pixels
    |> Enum.chunk_every(@width)
    # |> Enum.chunk_every(@height)
    |> Enum.each(fn row ->
      Enum.each(row, fn
        @black -> IO.write(" ")
        @white -> IO.write("x")
        @transparent -> IO.write(" ")
      end)

      IO.puts("")
    end)
  end
end
