import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :payments_api, PaymentsApi.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "payments_api_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :payments_api, PaymentsApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "iYru20r3WRQ8NHnr/tn6X6tAW/z+D8p2iEvVg3jg4jq6xXpeo3exP2AAWRRNjNtO",
  server: false

# In test we don't send emails.
config :payments_api, PaymentsApi.Mailer, adapter: Swoosh.Adapters.Test

config :payments_api, exchange_rate_store: ExchangeRateStoreMock

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :payments_api,
  exchange_rate_cache_expiration_in_seconds: 2,
  supported_currencies: [:CAD, :BRL, :USD],
  alpha_vantage_api_key: "SWV5BYTB8NODLZP8",
  alpha_vantage_api_url: "http://localhost:4001/query"
