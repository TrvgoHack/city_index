defmodule Indexer.Parser do
  def parse(file) do
    File.stream!(file)
    |> CSV.decode(separator: ?\t)
    |> Stream.map(&csv_to_point(&1))
    |> Stream.filter(fn record ->
      if Regex.run(~r/^PPL.*/, record.feature_code), do: true, else: false
    end)
    |> Stream.uniq
  end

  defp csv_to_point(row) do
    %Indexer.Point{
      id: Enum.at(row, 0),
      name: Enum.at(row, 1),
      country_code: Enum.at(row, 8),
      zip_code: Enum.at(row, 12),
      population: Enum.at(row, 14),
      lat: Enum.at(row, 4),
      lon: Enum.at(row, 5),
      feature_code: Enum.at(row, 7),
      alternate_names: []
    }
  end
end
