defmodule Indexer.SearchController do
  use Indexer.Web, :controller

  def search(conn, %{"lat" => lat, "lon" => lon, "radius" => radius}) do
    {lat, _} = Float.parse(lat)
    {lon, _} = Float.parse(lon)
    {radius, _} = Integer.parse(radius)
    {:ok, results} = Indexer.Searcher.lat_lon_search(lat, lon, radius)
    IO.inspect results

    results = results
    |> Enum.map(fn result ->
      result["_source"]["name"]
    end)
    |> :jiffy.encode([:use_nil])

    resp(conn, 200, results)
  end
end
