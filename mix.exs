defmodule ChainsparkApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :chainspark_api,
      version: "1.0.2",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ChainsparkApi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "priv/tasks"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, github: "phoenixframework/phoenix", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:guardian, "~> 1.2.0"},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 1.0"},
      {:ja_serializer, "~> 0.13.0"},
      {:ecto_enum, "~> 1.0"},
      {:ex_machina, "~> 2.2", only: :test},
      {:csv, "~> 1.2.3"},
      {:httpoison, "~> 1.0"},
      {:cors_plug, "~> 1.5"},
      {:crypto_compare, git: "https://github.com/AgileAlpha/crypto_compare.git"},
      {:distillery, "~> 2.0"},
      {:scrivener_ecto, "~> 1.3"},
      {:google_api_big_query , "~> 0.0.1"},
      {:goth, git: "https://github.com/tzumby/goth.git"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
