defmodule Indexer.Router do
  use Indexer.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Indexer do
    pipe_through :api

    get "/by_lat_lon", SearchController, :by_lat_lon
    post "/cities", SearchController, :cities
  end
end
