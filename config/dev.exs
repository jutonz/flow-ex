import Config

config :flow,
  #monitors: [
    #%{pin: 24, log_id: "cba36eac-41bd-4230-a89b-4bf694dd8980"}
  #],
  scale: [
    disabled: true
  ],
  humidity: [
    mode: :humidify,
    min_level: 30,
    max_level: 40,
    adjustment_cooldown: 15, # minutes
    awair_ip: "192.168.1.189",
    humidifier_on_url: "https://maker.ifttt.com/trigger/humidifier_on/with/key/dEtENNEyd63z0CIGBLTp1_",
    humidifier_off_url: "https://maker.ifttt.com/trigger/humidifier_off/with/key/dEtENNEyd63z0CIGBLTp1_",
  ]
