defmodule Flow.Screen do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    now = Time.utc_now()
    initial_state = %{awake: false, last_wake_at: now, last_sleep_at: now}
    {:ok, initial_state, {:continue, nil}}
  end

  def handle_continue(nil, state) do
    wake()
    {:noreply, state}
  end

  def wake do
    GenServer.cast(__MODULE__, :wake)
  end

  def sleep do
    GenServer.cast(__MODULE__, :sleep)
  end

  def handle_cast(:wake, state) do
    %{
      awake: awake,
      last_wake_at: last_wake_at
    } = state

    new_state =
      if !awake || Time.diff(Time.utc_now(), last_wake_at, :second) > 60 do
        Logger.info("Waking screen")
        provider().wake()
        %{state | awake: true, last_wake_at: Time.utc_now()}
      else
        state
      end

    {:noreply, new_state}
  end

  def handle_cast(:sleep, state) do
    %{
      awake: awake,
      last_sleep_at: last_sleep_at
    } = state

    now = Time.utc_now()

    new_state =
      if awake || Time.diff(now, last_sleep_at, :second) > 60 do
        Logger.info("Sleeping screen")
        provider().sleep()
        %{state | awake: false, last_sleep_at: now}
      else
        state
      end

    {:noreply, new_state}
  end

  defp provider do
    Application.fetch_env!(:flow, :screen_provider)
  end
end
