defmodule Indexer.Foo do
  def group_by_distance(data, step_distance) do
    steps = data
    |> Map.get("routes")
    |> List.first
    |> Map.get("legs")
    |> List.first
    |> Map.get("steps")

    last_coord = steps
    |> List.last
    |> step_location

    coord_steps_by_distance(steps, step_distance) ++ [last_coord]
    |> Enum.map(&run_search(&1))
  end

  defp coord_steps_by_distance(steps, step_distance) do
    Enum.reduce(steps, {0, []}, fn step, {distance_covered, steps} ->
      distance_covered = distance_covered + step["distance"]["value"]
      if distance_covered >= step_distance do
        {0, steps ++ [step_location(step)]}
      else
        {distance_covered, steps}
      end
    end)
    |> Kernel.elem(1)
  end

  defp run_search(coord, radius \\ 10) do
    {:ok, results} = Indexer.Searcher.lat_lon_search(coord["lat"], coord["lng"], radius)
    cities = results
    |> Enum.map(fn result ->
      %{
        name: result["_source"]["name"],
        population: result["_source"]["population"],
        score: result["_score"]
      }
    end)
  end

  defp step_location(step) do
    step["end_location"]
  end

  def read_data do
    File.read!("/data/maps.json")
    |> :jiffy.decode([:use_nil, :return_maps])
  end
end
