defmodule ChainsparkApiWeb.Router do
  use ChainsparkApiWeb, :router

  pipeline :api do
    plug :accepts, ["json-api"]
    plug ChainsparkApiWeb.Plug.AuthAccessPipeline
    plug JaSerializer.ContentTypeNegotiation
    plug JaSerializer.Deserializer
  end

  pipeline :api_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :app_access do
    plug ChainsparkApiWeb.Plug.AppAccess
  end

  pipeline :browser do
    plug :accepts, ["html"]
  end

  scope "/", ChainsparkApiWeb do
    pipe_through :browser

    get "/healthz", HeartbeatController, :index
  end

  scope "/api", ChainsparkApiWeb do

    pipe_through :api
    get "/transactions/highest", TransactionController, :highest
    post "/transactions", TransactionController, :create

    pipe_through :app_access
    resources "/transactions", TransactionController, only: [:index]
    resources "/tokens", TokenController, only: [:index, :show]
    resources "/wallets", WalletController, only: [:index, :show]
    resources "/entities", EntityController, only: [:show, :index]

    scope "/auth" do
      post "/login", SessionController, :create
    end

    pipe_through :api_auth
    post "/wallets", WalletController, :create
  end
end
