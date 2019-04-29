# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :conduit,
  ecto_repos: [Conduit.Repo]

# config migration
config :conduit, Conduit.Repo,
  migration_timestamps: [type: :utc_datetime, inserted_at: :created_at]

config :conduit, ConduitWeb.Guardian,
  issuer: "conduit",
  secret_key: "les4jsIJ5iYkbct35VAk9jWSUyewfmMV9nNEhpYvVF3ZaRjGOO9SzlOfB3A3tltf"

# Configures the endpoint
config :conduit, ConduitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yKlhOOKb3JMbeHY3mSZi/cDSJrhkzi9aWeAwLuRmzguxqeavrtcD1b4U8CCvii/q",
  render_errors: [view: ConduitWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Conduit.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
