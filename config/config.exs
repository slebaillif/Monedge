# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :monedge,
  ecto_repos: [Monedge.Repo]

# Configures the endpoint
config :monedge, Monedge.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/P/4BECsGq6hb/tEFQuiytqjOqGCFl6HOpJwOuMDwnFf3d8tPC6acja8zpaDnIgl",
  render_errors: [view: Monedge.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Monedge.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
