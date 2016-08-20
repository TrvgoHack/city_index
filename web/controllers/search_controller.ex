defmodule Indexer.SearchController do
  use Indexer.Web, :controller

  def search(conn, %{"lat" => lat, "lon" => lon, "radius" => radius}) do
    {lat, _} = Float.parse(lat)
    {lon, _} = Float.parse(lon)
    {radius, _} = Integer.parse(radius)
    {:ok, results} = Indexer.Searcher.lat_lon_search(lat, lon, radius)

    results = results
    |> Enum.map(fn result ->
      %{
        name: result["_source"]["name"],
        population: result["_source"]["population"],
        score: result["_score"]
      }
    end)

    {:ok, json} = %{
      cities: results
    }
    |> Poison.encode

    resp(conn, 200, json)
  end
end
