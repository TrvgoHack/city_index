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
        score: result["_score"]
      }
    end)
    |> :jiffy.encode([:use_nil])

    resp(conn, 200, results)
  end
end
