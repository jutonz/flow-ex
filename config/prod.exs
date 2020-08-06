import Config

config :flow,
  api_key: System.fetch_env!("FLOW_API_KEY"),
  monitors: [
    %{pin: 24, log_id: "f150cb6e-f0e0-4674-a5cc-a22b3fa3df28"}
  ],
  screen_provider: Flow.Screen.LinuxProvider

config :logger, level: :debug
