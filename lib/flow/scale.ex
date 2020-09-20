defmodule Flow.Scale do
  require Logger
  use GenServer
  alias Circuits.GPIO

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [])
  end

  def init(_args) do
    state = %{
      dt_pin: 29,
      sck_pin: 31,
      gain: 1
    }

    {:ok, state, {:continue, nil}}
  end

  def handle_continue(nil, state) do
    new_state =
      state
      |> Map.put(:dt_gpio, setup_dt(state[:dt_pin]))
      |> Map.put(:sck_gpio, setup_sck(state[:sck_pin]))

    reset(new_state[:sck_gpio])

    # Process.send(:set_gain)

    {:noreply, state}
  end

  # def handle_info(:set_gain, %{gain: gain} = state) do
  # gain_mode =
  # case gain do
  # 128 -> 1 # Channel A; gain factor 128
  # 64 -> 3  # Channel A; gain factor 64
  # 32 -> 2  # Channel B; gain factor 32
  # end
  # end

  defp setup_dt(pin) do
    Logger.info("Setting up dt on pin #{pin}")
    {:ok, gpio} = GPIO.open(pin, :input)
    GPIO.set_pull_mode(gpio, :pullup)
    # GPIO.set_interrupts(gpio, :falling)
    gpio
  end

  defp setup_sck(pin) do
    Logger.info("Setting up sck on pin #{pin}")
    {:ok, gpio} = GPIO.open(pin, :output)
    gpio
  end

  defp reset(sck_gpio) do
    shutdown(sck_gpio)
    startup(sck_gpio)
  end

  defp shutdown(sck_gpio) do
    # A shutdown is triggered by causing a rising edge on SCK for at least 60us
    GPIO.write(sck_gpio, 0)
    GPIO.write(sck_gpio, 1)
    # 1 millisecond == 100 microseconds
    Process.sleep(1)
  end

  defp startup(sck_gpio) do
    # Startup is triggered by lowering the SCK line
    GPIO.write(sck_gpio, 0)
    # wait 100us for startup
    Process.sleep(1)
  end
end
