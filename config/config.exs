# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :real_world, RealWorldWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AV4ejt8dSqrCBt3fcf6ItQXTyf2lvMa1MbHnpDqLy6fL6JoBgdhv2s1MI9jZUe2q",
  render_errors: [view: RealWorldWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RealWorld.PubSub,
  live_view: [signing_salt: "QWeGMYEk"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :real_world,
  conduit_backend_api_url: "https://conduit.productionready.io/api"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
