import Config

config :flow,
  api_key: System.get_env("FLOW_API_KEY"),
  screen_provider: Flow.Screen.NullProvider,
  socket_url: nil,
  monitors: []

import_config "#{Mix.env()}.exs"
