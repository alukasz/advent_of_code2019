defmodule AoC2019.Day14 do
  import NimbleParsec

  @day 14

  chemical =
    integer(min: 1, max: 5)
    |> ignore(string(" "))
    |> ascii_string([?A..?Z], min: 1, max: 5)
    |> optional(string(", ") |> ignore())

  defparsec(
    :reaction,
    repeat(chemical)
    |> tag(:input)
    |> concat(string(" => ") |> ignore())
    |> concat(chemical |> tag(:output))
  )

  @doc """
  iex> AoC2019.Day14.ore_required(AoC2019.Day14.input1())
  31
  iex> AoC2019.Day14.ore_required(AoC2019.Day14.input2())
  165
  iex> AoC2019.Day14.ore_required(AoC2019.Day14.input3())
  13312
  iex> AoC2019.Day14.ore_required(AoC2019.Day14.input4())
  180697
  iex> AoC2019.Day14.ore_required(AoC2019.Day14.input5())
  2210736
  """
  def ore_required(input \\ AoC2019.stream(@day)) do
    input
    |> reactions_map()
    |> ore(:FUEL, 1, %{})
    |> Map.get(:ORE)
  end

  defp ore(_reaction_map, :ORE, amount, acc) do
    Map.update(acc, :ORE, amount, &(&1 + amount))
  end

  defp ore(reaction_map, chemical, amount, acc) do
    case Map.get(acc, chemical, 0) do
      stored when stored >= amount ->
        Map.update!(acc, chemical, &(&1 - amount))

      stored ->
        {output, inputs} = find_inputs(reaction_map, chemical, amount - stored)

        excess = output - amount
        acc = Map.update(acc, chemical, excess, &(&1 + excess))

        Enum.reduce(inputs, acc, fn {chemical, amount}, acc ->
          ore(reaction_map, chemical, amount, acc)
        end)
    end
  end

  defp reactions_map(input) do
    input
    |> Enum.map(&parse_reaction/1)
    |> Enum.map(fn {inputs, {chemical, amount}} -> {chemical, {amount, inputs}} end)
    |> Enum.into(%{})
  end

  @doc """
  iex> AoC2019.Day14.parse_reaction("10 ORE => 10 A")
  {["ORE": 10], {:"A", 10}}
  iex> AoC2019.Day14.parse_reaction("7 A, 1 E => 1 FUEL")
  {["A": 7, "E": 1], {:"FUEL", 1}}
  """
  def parse_reaction(reaction) do
    {:ok, [{:input, inputs}, {:output, output}], "", _, _, _} = reaction(reaction)

    inputs =
      inputs
      |> Enum.chunk_every(2)
      |> Enum.map(&parse_chemical/1)

    {inputs, parse_chemical(output)}
  end

  defp parse_chemical([unit, name]), do: {String.to_atom(name), unit}

  defp find_inputs(map, output_chemical, required_amount) do
    {amount, inputs} = Map.get(map, output_chemical)
    times = Kernel.ceil(required_amount / amount)
    inputs =
      if times > 1 do
        Enum.map(inputs, fn {chemical, amount} -> {chemical, amount * times} end)
      else
        inputs
      end

    {amount * times, inputs}
  end

  def input1 do
    [
      "10 ORE => 10 A",
      "1 ORE => 1 B",
      "7 A, 1 B => 1 C",
      "7 A, 1 C => 1 D",
      "7 A, 1 D => 1 E",
      "7 A, 1 E => 1 FUEL"
    ]
  end

  def input2 do
    [
      "9 ORE => 2 A",
      "8 ORE => 3 B",
      "7 ORE => 5 C",
      "3 A, 4 B => 1 AB",
      "5 B, 7 C => 1 BC",
      "4 C, 1 A => 1 CA",
      "2 AB, 3 BC, 4 CA => 1 FUEL"
    ]
  end

  def input3 do
    [
      "157 ORE => 5 NZVS",
      "165 ORE => 6 DCFZ",
      "44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL",
      "12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ",
      "179 ORE => 7 PSHF",
      "177 ORE => 5 HKGWZ",
      "7 DCFZ, 7 PSHF => 2 XJWVT",
      "165 ORE => 2 GPVTF",
      "3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"
    ]
  end

  def input4 do
    [
      "2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG",
      "17 NVRVD, 3 JNWZP => 8 VPVL",
      "53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL",
      "22 VJHF, 37 MNCFX => 5 FWMGM",
      "139 ORE => 4 NVRVD",
      "144 ORE => 7 JNWZP",
      "5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC",
      "5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV",
      "145 ORE => 6 MNCFX",
      "1 NVRVD => 8 CXFTF",
      "1 VJHF, 6 MNCFX => 4 RFSQX",
      "176 ORE => 6 VJHF"
    ]
  end

  def input5 do
    [
      "171 ORE => 8 CNZTR",
      "7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL",
      "114 ORE => 4 BHXH",
      "14 VRPVC => 6 BMBT",
      "6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL",
      "6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT",
      "15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW",
      "13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW",
      "5 BMBT => 4 WPTQ",
      "189 ORE => 9 KTJDG",
      "1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP",
      "12 VRPVC, 27 CNZTR => 2 XDBXC",
      "15 KTJDG, 12 BHXH => 5 XCVML",
      "3 BHXH, 2 VRPVC => 7 MZWV",
      "121 ORE => 7 VRPVC",
      "7 XCVML => 6 RJRHP",
      "5 BHXH, 4 VRPVC => 5 LTCX"
    ]
  end
end
