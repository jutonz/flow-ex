import Config

config :flow,
  api_key: System.get_env("FLOW_API_KEY"),
  screen_provider: Flow.Screen.NullProvider,
  socket_url: "ws://localhost:4000/socket/websocket",
  monitors: [
    %{pin: 24, log_id: "f150cb6e-f0e0-4674-a5cc-a22b3fa3df28"}
  ]

import_config "#{Mix.env()}.exs"
