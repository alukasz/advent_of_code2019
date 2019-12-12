defmodule AoC2019.Day12 do
  @day 12

  @doc """
  iex> input = "<x=-1, y=0, z=2>\\n<x=2, y=-10, z=-7>\\n<x=4, y=-8, z=8>\\n<x=3, y=5, z=-1>"
  iex> AoC2019.Day12.simulate_gravity(input, 10)
  179
  iex> AoC2019.Day12.simulate_gravity()
  9441
  """
  def simulate_gravity(input \\ AoC2019.read(@day), rounds \\ 1000) do
    input
    |> parse()
    |> split_by_axis()
    |> Enum.map(&simulate(&1, 1..rounds))
    |> join_axis()
    |> calculate_total_energy()
  end

  defp simulate(axis, iterations) do
    Enum.reduce(iterations, axis, fn _, axis ->
      simulate_axis(axis)
    end)
  end

  defp simulate_axis({x1, x2, x3, x4}) do
    {x1, x2} = apply_gravity(x1, x2)
    {x1, x3} = apply_gravity(x1, x3)
    {x1, x4} = apply_gravity(x1, x4)
    {x2, x3} = apply_gravity(x2, x3)
    {x2, x4} = apply_gravity(x2, x4)
    {x3, x4} = apply_gravity(x3, x4)
    {apply_velocity(x1), apply_velocity(x2), apply_velocity(x3), apply_velocity(x4)}
  end

  defp apply_gravity({p1, v1}, {p2, v2}) when p1 > p2, do: {{p1, v1 - 1}, {p2, v2 + 1}}
  defp apply_gravity({p1, v1}, {p2, v2}) when p1 < p2, do: {{p1, v1 + 1}, {p2, v2 - 1}}
  defp apply_gravity(m1, m2), do: {m1, m2}

  defp apply_velocity({p, v}), do: {p + v, v}

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    Regex.scan(~r/([xyz])=(-?\d{1,2})/, line)
    |> Enum.map(fn [_, _, val] -> String.to_integer(val) end)
    |> Enum.map(&{&1, 0})
  end

  defp split_by_axis(moons) do
    moons = List.flatten(moons)

    [
      Enum.take_every(moons, 3),
      moons |> Enum.drop(1) |> Enum.take_every(3),
      moons |> Enum.drop(2) |> Enum.take_every(3)
    ]
    |> Enum.map(&List.to_tuple/1)
  end

  defp join_axis(axis) do
    {pos, vel} =
      axis
      |> Enum.map(&Tuple.to_list/1)
      |> List.flatten()
      |> Enum.unzip()

    Enum.map(0..3, fn to_drop ->
      {
        pos |> Enum.drop(to_drop) |> Enum.take_every(4),
        vel |> Enum.drop(to_drop) |> Enum.take_every(4)
      }
    end)
  end

  defp calculate_total_energy(moons) do
    Enum.reduce(moons, 0, &(&2 + energy(&1)))
  end

  defp energy({pos, vel}), do: energy(pos) * energy(vel)
  defp energy([x, y, z]), do: abs(x) + abs(y) + abs(z)

  @doc """
  iex> input = "<x=-1, y=0, z=2>\\n<x=2, y=-10, z=-7>\\n<x=4, y=-8, z=8>\\n<x=3, y=5, z=-1>"
  iex> AoC2019.Day12.repeat(input)
  2772
  """
  def repeat(input \\ AoC2019.read(@day)) do
    [a, b, c] =
      input
      |> parse()
      |> split_by_axis()
      |> Enum.map(&find_repeat/1)

    lcm(lcm(a, b), c)
  end

  defp find_repeat(axis) do
    if :states in :ets.all() do
      :ets.delete(:states)
    end
    :ets.new(:states, [:set, :named_table])
    Enum.reduce_while(Stream.iterate(0, &(&1 + 1)), axis, fn iteration, axis ->
      axis = simulate_axis(axis)
      case :ets.lookup(:states, {axis}) do
        [axis]->
          {:halt, iteration - elem(axis, 1)}

        [] ->
          :ets.insert(:states, {{axis}, iteration})
          {:cont, axis}
      end
    end)
  end

  def lcm(a,b), do: div(abs(a*b), Integer.gcd(a,b))
end
