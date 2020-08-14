defmodule Flow.FlowMonitor do
  require Logger
  use GenServer
  alias Circuits.GPIO
  alias Flow.Backend

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

  def init(%{pin: pin, log_id: log_id}) do
    initial_state = %{
      gpio: setup_gpio(pin),
      log_id: log_id,
      pulses: 0,
      last_pulse_at: nil
    }

    {:ok, initial_state, {:continue, nil}}
  end

  def handle_continue(nil, state) do
    schedule_checkin()
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, _pin, _timestamp, _value}, state) do
    if state[:pulses] == 0 do
      Flow.Screen.wake()
    end

    new_state =
      state
      |> Map.put(:pulses, state[:pulses] + 1)
      |> Map.put(:last_pulse_at, Time.utc_now())

    pulses = state[:pulses]
    ml = pulses_to_ml(pulses)
    Backend.set_ml(state[:log_id], ml)
    Logger.info("Pulse! Total: #{pulses}. Usage: #{ml} ml")

    {:noreply, new_state}
  end

  def handle_info(:maybe_reset, state) do
    pulses = state[:pulses]
    last_pulse_at = state[:last_pulse_at]

    new_state =
      cond do
        pulses > 0 && last_pulse_at && time_ago_in_seconds(last_pulse_at) > 3 ->
          upload_usage(state[:log_id], state[:pulses])
          %{state | pulses: 0}

        pulses == 0 && last_pulse_at && time_ago_in_seconds(last_pulse_at) > 10 ->
          Flow.Screen.sleep()
          state

        true ->
          state
      end

    schedule_checkin()

    {:noreply, new_state}
  end

  defp setup_gpio(pin) do
    Logger.info("Setting up GPIO pin #{pin}")
    {:ok, gpio} = GPIO.open(pin, :input)
    GPIO.set_pull_mode(gpio, :pullup)
    GPIO.set_interrupts(gpio, :falling)
    gpio
  end

  defp schedule_checkin,
    do: Process.send_after(self(), :maybe_reset, 1000)

  defp upload_usage(log_id, pulses) do
    ml = pulses_to_ml(pulses)

    if ml > 0 do
      Logger.info("Uploading usage of #{ml} ml...")
      Backend.commit(log_id, ml)
    end
  end

  @ideal_pulses_per_liter 4380
  @pulse_adjustor -575
  @pulses_per_liter @ideal_pulses_per_liter + @pulse_adjustor
  defp pulses_to_ml(pulses) do
    liters = pulses / @pulses_per_liter
    trunc(liters * 1000)
  end

  defp time_ago_in_seconds(time) do
    Time.diff(Time.utc_now(), time, :second)
  end
end
