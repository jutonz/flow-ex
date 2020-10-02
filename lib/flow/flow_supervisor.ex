defmodule Flow.FlowSupervisor do
  require Logger
  use Supervisor

  def start_link(_arg),
    do: Supervisor.start_link(__MODULE__, :ok)

  def init(:ok) do
    children =
      Enum.flat_map(monitors(), fn args ->
        [{Flow.FlowMonitor, args}, {Flow.Scale, args}]
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp monitors,
    do: Application.fetch_env!(:flow, :monitors)
end
