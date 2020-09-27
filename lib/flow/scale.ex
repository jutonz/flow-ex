defmodule Flow.Scale do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    initial_state = %{}
    {:ok, initial_state, {:continue, nil}}
  end

  def handle_continue(nil, state) do
    {:ok, py_pid} = :python.start()
    send(self(), :check)
    {:noreply, Map.put(state, :py_pid, py_pid)}
  end

  def handle_info(:check, %{py_pid: pid} = state) do
    version = :python.call(pid, :sys, :"version.__str__", [])
    Logger.info(version)
    {:noreply, state}
  end
end
