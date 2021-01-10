import Config

config :flow,
  api_key: System.get_env("FLOW_API_KEY"),
  screen_provider: Flow.Screen.NullProvider,
  socket_url: nil,
  monitors: []

config :logger,
  backends: [:console, Sentry.LoggerBackend]

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env(),
  included_environments: [:prod],
  enable_source_code_context: true,
  root_source_code_path: [File.cwd!()]

import_config "#{Mix.env()}.exs"
