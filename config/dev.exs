import Config

config :flow,
  monitors: [
    %{pin: 24, log_id: "cba36eac-41bd-4230-a89b-4bf694dd8980"}
  ],
  socket_url: "ws://localhost:4000/socket/websocket"
