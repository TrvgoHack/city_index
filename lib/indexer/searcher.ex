defmodule Indexer.Searcher do
  require Logger

  def lat_lon_search(lat, lon, distance) do
    query = lat_lon_query(lat, lon, distance)
    {:ok, body} = search(query)
    body
  end

  def search(query) do
    query = :jiffy.encode(query, [:use_nil])

    case HTTPoison.post(elasticsearch_url, query, [], http_options) do
      {:ok, %{status_code: 200, body: body}} ->
        body = :jiffy.decode(body, [:return_maps])
                |> parse_results
        {:ok, body}
      {_, response} ->
        Logger.error("No valid response from Elasticsearch: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp lat_lon_query(lat, lon, distance) do
    %{
      query: %{
        function_score: %{
          query: %{
            bool: %{
              must: [
                %{
                  geo_distance: %{
                    distance: "#{distance}km",
                    location: %{
                      lat: lat,
                      lon: lon
                    }
                  }
                }
              ]
            }
          },
          functions: [
            %{
              gauss: %{
                location: %{
                  origin: %{
                    lat: lat,
                    lon: lon
                  },
                  offset: "#{distance / 2}km",
                  scale: "#{distance / 2}km"
                }
              }
            },
            %{
              field_value_factor: %{
                field: "population",
                factor: 0.1
              }
            }
          ]
        }
      }
    }
  end

  defp elasticsearch_url do
    "http://#{System.get_env("ELASTICSEARCH_PORT_9200_TCP_ADDR")}:#{System.get_env("ELASTICSEARCH_PORT_9200_TCP_PORT")}/cities/_search?size=5"
  end

  defp http_options do
    []
  end

  defp parse_results(results) do
    results
    |> Map.get("hits")
    |> Map.get("hits")
  end
end
