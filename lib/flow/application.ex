defmodule Flow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Flow.FlowSupervisor,
      Flow.HumidityManager,
      Flow.HumidityMonitor,
      Flow.Screen,
      worker(Flow.Backend, []),
      {Finch, name: FlowFinch}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Flow.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
