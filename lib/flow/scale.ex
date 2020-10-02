defmodule Flow.Scale do
  alias Flow.Backend
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(%{log_id: log_id}) do
    initial_state = %{log_id: log_id}
    {:ok, initial_state, {:continue, nil}}
  end

  def handle_continue(nil, state) do
    {:ok, py_pid} =
      :python.start(python_path: to_char_list("/home/pi/code/jutonz/flow-ex/vendor"))

    setup_scale(py_pid)
    send(self(), :get_measurement)
    {:noreply, Map.put(state, :py_pid, py_pid)}
  end

  def handle_info(:get_measurement, %{py_pid: pid, log_id: log_id} = state) do
    value = get_measurement(pid)
    value = max(0, value)
    if value > 2, do: log("Got measurement: #{value}")
    Backend.weight(log_id, value)
    schedule_measurement()
    {:noreply, state}
  end

  def terminate(_reason, %{py_pid: pid} = _state) do
    log("Received terminate. Cleaning up...")
    cleanup(pid)
    :normal
  end

  defp schedule_measurement do
    Process.send_after(self(), :get_measurement, 1000)
  end

  defp get_measurement(pid) do
    :python.call(pid, :scale, :get_measurement, [])
  end

  defp setup_scale(pid) do
    log("Initializing scale...")
    :python.call(pid, :scale, :setup, [])
    log("Scale initialized")
  end

  defp cleanup(pid) do
    :python.call(pid, :scale, :teardown, [])
  end

  defp log(message) do
    Logger.info("[#{__MODULE__}] #{message}")
  end
end
