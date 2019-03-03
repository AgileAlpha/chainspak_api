use Mix.Config

config :logger, level: :debug

config :chainspark_api, ChainsparkApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: false

#This is the Google BigTable credential
#config :goth,
#  json: "google_creds.json" |> File.read!
