import Config

config :flow,
  api_key: System.fetch_env!("FLOW_API_KEY"),
  monitors: [
    %{pin: 24, log_id: "f150cb6e-f0e0-4674-a5cc-a22b3fa3df28"}
  ],
  scale: [
    disabled: false
  ],
  screen_provider: Flow.Screen.LinuxProvider,
  socket_url: "wss://app.jutonz.com/socket/websocket",
  humidity: [
    mode: :humidify,
    target_humidity: 43,
    adjustment_cooldown_minutes: 15,
    awair_ip: "192.168.1.189",
    ifttt_key: System.fetch_env!("IFTTT_KEY")
  ]

config :logger, level: :debug
