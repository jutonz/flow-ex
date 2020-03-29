defmodule Flow.FlowMonitor do
  use GenServer
  alias Circuits.GPIO

  @sensor_gpio 18

  @ideal_pulses_per_liter 4380
  @pulse_adjustor -575
  @pulses_per_liter @ideal_pulses_per_liter + @pulse_adjustor

  def start_link(args),
    do: GenServer.start_link(__MODULE__, :ok, args)

  def init(:ok) do
    {:ok, sensor_gpio} = GPIO.open(@sensor_gpio, :input)
    GPIO.set_interrupts(sensor_gpio, :rising)

    {:ok, :no_state}
  end
end
