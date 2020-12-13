import Config

config :flow,
  # monitors: [
  # %{pin: 24, log_id: "cba36eac-41bd-4230-a89b-4bf694dd8980"}
  # ],
  scale: [
    disabled: true
  ],
  humidity: [
    # mode: :humidify,
    min_level: 35,
    max_level: 40,
    adjustment_cooldown: 15,
    awair_ip: "192.168.1.189"
    # ifttt_key: System.fetch_env!("IFTTT_KEY")
  ]
