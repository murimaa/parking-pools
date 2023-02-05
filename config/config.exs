# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :parking_pool_web,
  generators: [context_app: false]

# Configures the endpoint
config :parking_pool_web, ParkingPoolWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ParkingPoolWeb.ErrorHTML, json: ParkingPoolWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ParkingPoolWeb.PubSub,
  live_view: [signing_salt: "neJmk15S"]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/parking_pool_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
