import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_cursor, LiveCursorWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "PqY/gr+OnIKzggq+1SNmBUCjiXSQoT9cUKwotKOG9PdhIYk3HQrBSsJ5j4M6KcUh",
  server: false

# In test we don't send emails.
config :live_cursor, LiveCursor.Mailer,
  adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
