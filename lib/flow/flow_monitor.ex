defmodule Flow.FlowMonitor do
  use GenServer
  alias Circuits.GPIO

  @sensor_gpio 18

  #@ideal_pulses_per_liter 4380
  #@pulse_adjustor -575
  #@pulses_per_liter @ideal_pulses_per_liter + @pulse_adjustor

  def start_link(args),
    do: GenServer.start_link(__MODULE__, :ok, debug: [:trace])

  def init(:ok) do
    {:ok, sensor_gpio} = GPIO.open(@sensor_gpio, :input)
    GPIO.set_pull_mode(sensor_gpio, :pullup)

    int_opts = [suppress_glitches: false]
    GPIO.set_interrupts(sensor_gpio, :falling, int_opts)

    {:ok, %{gpio: sensor_gpio}}
  end
end
