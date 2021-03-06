defmodule Indexer.SearchController do
  use Indexer.Web, :controller

  def by_lat_lon(conn, %{"lat" => lat, "lon" => lon, "radius" => radius}) do
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

  def by_coords(%Plug.Conn{body_params: %{"coords" => coords}} = conn, params) do
    result = coords
    |> Enum.map(fn coord ->
      cities = Indexer.Searcher.lat_lon_search(coord["lat"], coord["lon"], coord["radius"])
      |> Enum.map(fn city ->
        %{
          name: city["_source"]["name"],
          coord: city["_source"]["location"],
          country_code: city["_source"]["country_code"]
        }
      end)
      %{
        query: coord,
        cities: cities
      }
    end)

    result = %{
      result: result
    }

    json = :jiffy.encode(result, [:use_nil])
    resp(conn, 200, json)
  end

  def by_name(conn, %{"name" => name}) do
    cities = Indexer.Searcher.name_search(name)
    |> Enum.map(fn city ->
      %{
        name: city["_source"]["name"],
        coord: city["_source"]["location"],
        country_code: city["_source"]["country_code"]
      }
    end)

    cities = %{
      cities: cities
    }

    json = :jiffy.encode(cities, [:use_nil])
    resp(conn, 200, json)
  end
end
