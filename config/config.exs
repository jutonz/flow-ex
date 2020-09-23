import Config

config :flow,
  api_key: System.get_env("FLOW_API_KEY"),
  screen_provider: Flow.Screen.NullProvider,
  socket_url: "ws://localhost:4000/socket/websocket",
  monitors: [
    %{pin: 24, log_id: "2aa4bca0-e720-4711-9513-d921cbd7c749"}
  ]

import_config "#{Mix.env()}.exs"
