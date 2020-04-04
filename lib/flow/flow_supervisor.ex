defmodule Flow.FlowSupervisor do
  use DynamicSupervisor

  def start_link(_arg),
    do: DynamicSupervisor.start_link(__MODULE__, :ok)

  def init(:ok) do
    spawn(&start_monitors/0)
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_monitors,
    do: Enum.each(monitors(), &start_monitor/1)

  defp start_monitor(args),
    do: DynamicSupervisor.start_child(__MODULE__, {Flow.FlowMonitor, args})

  defp monitors,
    do: Application.fetch_env!(:flow, :monitors)
end
