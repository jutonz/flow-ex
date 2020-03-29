defmodule Flow.FlowMonitor do
  use GenServer
  alias Circuits.GPIO
  alias Flow.Api

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, debug: [:trace])

  def init(%{pin: pin, log_id: log_id}) do
    schedule_checkin()

    initial_state = %{
      gpio: setup_gpio(pin),
      log_id: log_id,
      pulses: 0
    }

    {:ok, initial_state}
  end

  def handle_info({:circuits_gpio, _pin, _timestamp, _value}, state) do
    new_state =
      state
      |> Map.put(:pulses, state[:pulses] + 1)
      |> Map.put(:last_pulse, Time.utc_now())

    {:noreply, new_state}
  end

  def handle_info(:maybe_reset, %{last_pulse: last_pulse} = state) do
    if Time.diff(Time.utc_now(), last_pulse, :second) > 10 do
      upload_usage(state[:log_id], state[:pulses])
      {:noreply, %{state | pulses: 0}}
    else
      {:noreply, state}
    end
  end

  defp setup_gpio(pin) do
    {:ok, gpio} = GPIO.open(pin, :input)
    GPIO.set_pull_mode(gpio, :pullup)
    GPIO.set_interrupts(gpio, :falling)
  end

  defp schedule_checkin,
    do: Process.send_after(self(), 1000, :maybe_reset)

  @ideal_pulses_per_liter 4380
  @pulse_adjustor -575
  @pulses_per_liter @ideal_pulses_per_liter + @pulse_adjustor
  defp upload_usage(log_id, pulses) do
    liters = pulses / @pulses_per_liter
    ml = trunc(liters * 1000)
    Api.upload(log_id, ml)
  end
end