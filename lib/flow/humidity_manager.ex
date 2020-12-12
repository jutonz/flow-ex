defmodule Flow.HumidityManager do
  require Logger
  use GenServer

  @debug true

  def start_link(args) do
    genserver_opts =
      if @debug do
        [debug: [:trace], name: __MODULE__]
      else
        []
      end

    GenServer.start_link(__MODULE__, args, genserver_opts)
  end

  def init(_args) do
    initial_state = %{
      last_adjustment_at: nil
    }
    {:ok, initial_state}
  end

  def humidity_callback(value) do
    GenServer.cast(__MODULE__, {:humidity, value})
  end

  def humidifier_on do
    GenServer.cast(__MODULE__, :humidifier_on)
  end

  def humidifier_off do
    GenServer.cast(__MODULE__, :humidifier_off)
  end

  def handle_cast({:humidity, value}, state) do
    cooldown_elapsed = cooldown_elapsed?(state)
    adjustment = adjustment(value)
    Logger.info("Humidity is #{value}; action is #{adjustment}")

    if cooldown_elapsed && adjustment == :humidifier_on do
      humidifier_on()
    end

    if cooldown_elapsed && adjustment == :humidifier_off do
      humidifier_off()
    end

    {:noreply, state}
  end

  def handle_cast(:humidifier_on, state) do
    Logger.info("turning humidifier on")

    new_state = %{
      last_adjustment_at: now()
    }

    {:noreply, Map.merge(state, new_state)}
  end

  def handle_cast(:humidifier_off, state) do
    Logger.info("turning humidifier off")

    new_state = %{
      last_adjustment_at: now()
    }

    {:noreply, Map.merge(state, new_state)}
  end

  @spec adjustment(float()) :: :humidifier_on | :humidifier_off | :nothing
  defp adjustment(value) do
    cond do
      value < min_level() -> :humidifier_on
      value > max_level() -> :humidifier_off
      true -> :nothing
    end
  end

  defp cooldown_elapsed?(%{last_adjustment_at: nil}) do
    true
  end

  defp cooldown_elapsed?(state) do
    last_adjustment_at = state[:last_adjustment_at]
    cooldown_seconds = adjustment_cooldown() * 60
    cooldown_expires_at = DateTime.add(last_adjustment_at, cooldown_seconds, :second)

    DateTime.compare(cooldown_expires_at, now()) == :lt
  end

  @zone "Etc/UTC"
  defp now do
    DateTime.now!(@zone)
  end

  defp adjustment_cooldown do
    Application.fetch_env!(:flow, :humidity)[:adjustment_cooldown]
  end

  defp min_level do
    Application.fetch_env!(:flow, :humidity)[:min_level]
  end

  defp max_level do
    Application.fetch_env!(:flow, :humidity)[:min_level]
  end
end
