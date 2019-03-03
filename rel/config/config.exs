use Mix.Config

port = String.to_integer(System.get_env("PORT") || "4000")

config :chainspark_api, :coinmcap_api_key, System.get_env("COINCAP_API_KEY")
config :chainspark_api, :app_access_key, System.get_env("APP_ACCESS_KEY")

config :chainspark_api, ChainsparkApiWeb.Endpoint,
  http: [port: port],
  url: [scheme: "http", host: System.get_env("HOST"), port: port],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: ChainsparkApiWeb.ErrorView, accepts: ~w(json json-api)],
  pubsub: [name: ChainsparkApi.PubSub, adapter: Phoenix.PubSub.PG2],
  check_origin: false,
  server: true

config :chainspark_api, ChainsparkApi.Guardian,
  issuer: "chainspark_api",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

config :stripy,
  secret_key: System.get_env("STRIPE_SECRET_KEY"),
  httpoison: [recv_timeout: 5000, timeout: 8000]
