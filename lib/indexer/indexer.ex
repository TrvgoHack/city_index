defmodule Indexer.Indexer do
  alias Indexer.Parser
  require Logger

  def run(path) do
    Path.wildcard(path)
    |> Enum.each(fn file ->
      Parser.parse(file)
      |> Stream.map(&to_doc(&1))
      |> Stream.chunk(100, 100, [])
      |> Stream.map(&to_batch(&1))
      |> Stream.run
    end)
  end

  def to_doc(point) do
    %{
      name: point.name,
      country_code: point.country_code,
      zip_code: point.zip_code,
      alternate_names: point.alternate_names,
      population: point.population,
      feature_code: point.feature_code,
      location: %{
        lat: point.lat,
        lon: point.lon
      }
    }
  end

  def to_batch(docs) do
    docs
    |> Enum.map(fn doc ->
      [%{index: %{_index: "cities", _type: "city"}}, doc]
    end)
    |> List.flatten
    |> index_batch
  end

  def index_batch(batch) do
    batch = batch
    |> Enum.map(fn row ->
      :jiffy.encode(row, [:use_nil])
    end)
    |> Enum.join("\n")
    batch = batch <> "\n"

    case HTTPoison.post(elasticsearch_url, batch, [], http_options) do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.debug("Indexed batch")
        {:ok, nil}
      {:ok, %{status_code: 201, body: body}} ->
        Logger.debug("Indexed batch")
        {:ok, nil}
      {_, response} ->
        Logger.error("No valid response from Elasticsearch: #{inspect(response)}")
        {:error, :invalid_response}
    end
  end

  defp elasticsearch_url do
    "http://#{System.get_env("ELASTICSEARCH_PORT_9200_TCP_ADDR")}:#{System.get_env("ELASTICSEARCH_PORT_9200_TCP_PORT")}/_bulk"
  end

  defp http_options do
    []
  end
end
