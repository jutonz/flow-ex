defmodule Flow.SocketClient do
  require Logger
  alias Phoenix.Channels.GenSocketClient
  @behaviour GenSocketClient
  def start_link do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      socket_url(),
      [],
      name: __MODULE__
    )
  end

  def init(url) do
    query_params = [token: token()]
    initial_state = %{topics: initial_topics()}
    {:connect, url, query_params, initial_state}
  end

  def set_ml(log_id, ml) do
    Process.send(__MODULE__, {:set_ml, log_id, ml}, [])
  end

  def commit(log_id, ml) do
    Process.send(__MODULE__, {:commit, log_id, ml}, [])
  end

  def handle_connected(_transport, %{topics: topics} = state) do
    Logger.info("Connected")
    Enum.each(topics, fn topic -> Process.send(self(), {:join, topic}, []) end)
    {:ok, state}
  end

  def handle_disconnected(_reason, state) do
    Logger.info("Disconnected: #{inspect(state)}")
    Process.send_after(self(), :connect, :timer.seconds(5))
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.info("Server disconnected from topic #{topic}: #{inspect(payload)}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(5))
    {:ok, state}
  end

  def handle_joined(topic, _payload, _transport, state) do
    Logger.info("Joined topic: #{topic}")
    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.error("Failed to join topic #{topic}: #{inspect(payload)}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(5))
    {:ok, state}
  end

  def handle_info({:join, topic}, transport, state) do
    Logger.info("Joining topic #{topic}")
    GenSocketClient.join(transport, topic)
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("Connecting")
    {:connect, state}
  end

  def handle_info({:set_ml, log_id, ml}, transport, state) do
    topic = topic_for_log_id(log_id)
    event = "set_ml"
    payload = %{"ml" => ml}
    GenSocketClient.push(transport, topic, event, payload)
    {:ok, state}
  end

  def handle_info({:commit, log_id, ml}, transport, state) do
    topic = topic_for_log_id(log_id)
    event = "commit"
    payload = %{"ml" => ml}
    GenSocketClient.push(transport, topic, event, payload)
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    Logger.info("Received reply to on topic #{topic}: #{inspect(payload)}")
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    Logger.warn("Unkonwn message on topic #{topic}: #{event} #{inspect(payload)}")
    {:ok, state}
  end

  def handle_call(message, _from, _transport, state) do
    Logger.warn("Received unknown handle_call with message #{inspect(message)}")
    {:ok, state}
  end

  defp token do
    Application.fetch_env!(:flow, :api_key)
  end

  defp socket_url do
    Application.fetch_env!(:flow, :socket_url)
  end

  def initial_topics do
    Enum.map(Application.fetch_env!(:flow, :monitors), fn %{log_id: log_id} ->
      topic_for_log_id(log_id)
    end)
  end

  defp topic_for_log_id(log_id),
    do: "water_log:#{log_id}"
end
