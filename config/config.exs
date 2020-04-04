import Config

config :flow, api_key: System.get_env("FLOW_API_KEY")

import_config "#{Mix.env()}.exs"
