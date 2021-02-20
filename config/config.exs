import Config

config :flow,
  api_key: System.get_env("FLOW_API_KEY"),
  screen_provider: Flow.Screen.NullProvider,
  socket_url: nil,
  monitors: [],
  digital_ocean: [
    api_token: System.get_env("DIGITAL_OCEAN_API_TOKEN"),
    domain: "jutonz.com",
    record_id: "134052056"
  ]

config :logger,
  backends: [:console, Sentry.LoggerBackend]

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env(),
  included_environments: [:prod],
  enable_source_code_context: true,
  root_source_code_path: [File.cwd!()]

import_config "#{Mix.env()}.exs"
