import Config

config :flow, api_key: System.fetch_env!("FLOW_API_KEY")
