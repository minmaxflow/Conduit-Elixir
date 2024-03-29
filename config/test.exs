use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :conduit, ConduitWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :comeonin, :bcrypt_log_rounds, 1

# Configure your database
config :conduit, Conduit.Repo,
  username: "root",
  password: "",
  database: "conduit_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  charset: "utf8mb4"
