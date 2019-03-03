use Mix.Config

config :chainspark_api, :app_access_key, "123"
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chainspark_api, ChainsparkApiWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :chainspark_api, ChainsparkApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "chainspark_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :chainspark_api, ChainsparkApi.Guardian,
  issuer: "chainspark_api",
  secret_key: "test_secret"

config :goth,
  disabled: true
