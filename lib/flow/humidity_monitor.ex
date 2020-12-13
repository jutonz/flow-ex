defmodule Flow.HumidityMonitor do
  require Logger
  use GenServer

  alias Flow.{
    Awair,
    HumidityManager
  }

  @debug false

  def start_link(args) do
    genserver_opts =
      if @debug do
        [debug: [:trace]]
      else
        []
      end

    GenServer.start_link(__MODULE__, args, genserver_opts)
  end

  def init(_args) do
    initial_state = %{
      awair_ip: awair_ip()
    }

    {:ok, initial_state, {:continue, nil}}
  end

  def handle_continue(nil, state) do
    schedule_checkin()
    {:noreply, state}
  end

  def handle_info(:check, %{awair_ip: ip} = state) do
    {:ok, humidity} = Awair.humidity(ip)
    HumidityManager.humidity_callback(humidity)
    schedule_checkin()
    {:noreply, state}
  end

  @check_every 60_000
  defp schedule_checkin do
    Process.send_after(self(), :check, @check_every)
  end

  defp awair_ip do
    Application.fetch_env!(:flow, :humidity)[:awair_ip]
  end
end
