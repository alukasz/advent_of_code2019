defmodule AoC2019.Day12 do
  @day 12

  defmodule Moon do
    defstruct [:id, :pos, vel: {0, 0, 0}]
  end

  @doc """
  iex> input = "<x=-1, y=0, z=2>\\n<x=2, y=-10, z=-7>\\n<x=4, y=-8, z=8>\\n<x=3, y=5, z=-1>"
  iex> AoC2019.Day12.simulate_gravity(input, 10)
  179
  """
  def simulate_gravity(input \\ AoC2019.read(@day), rounds \\ 1000) do
    moons = parse(input)

    Enum.reduce(1..rounds, moons, fn _, moons ->
      moons
      |> apply_gravity()
      |> apply_velocity()
    end)
    |> calculate_total_energy()
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, index} -> %Moon{id: index, pos: parse_line(line)} end)
  end

  defp parse_line(line) do
    Regex.scan(~r/([xyz])=(-?\d{1,2})/, line)
    |> Enum.map(fn [_, _, val] -> String.to_integer(val) end)
    |> List.to_tuple()
  end

  defp apply_gravity(moons) do
    Enum.map(moons, fn moon ->
      Enum.reduce(moons, moon, fn
        %{id: id1} = other, %{id: id2} = moon when id1 != id2 ->
          apply_gravity(moon, other)

        _, moon ->
          moon
      end)

    end)
  end

  defp apply_gravity(moon, other) do
    Enum.reduce(0..2, moon, fn index, moon ->
      case {elem(moon.pos, index), elem(other.pos, index)} do
        {p, p} ->
          moon

        {p1, p2} when p1 > p2 ->
          velocity = elem(moon.vel, index)
          %{moon | vel: put_elem(moon.vel, index, velocity - 1)}

        {p1, p2} when p1 < p2 ->
          velocity = elem(moon.vel, index)
          %{moon | vel: put_elem(moon.vel, index, velocity + 1)}
      end
    end)
  end

  defp apply_velocity(moons) do
    Enum.map(moons, fn moon ->
      Enum.reduce(0..2, moon, fn index, moon ->
        velocity = elem(moon.vel, index)
        position = elem(moon.pos, index)
        %{moon | pos: put_elem(moon.pos, index, position + velocity)}
      end)
    end)
  end

  defp calculate_total_energy(moons) do
    Enum.reduce(moons, 0, fn %{pos: pos, vel: vel}, energy ->
      energy + sum_tuple(pos) * sum_tuple(vel)
    end)
  end

  defp sum_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(&abs/1)
    |> Enum.sum()
  end
end
