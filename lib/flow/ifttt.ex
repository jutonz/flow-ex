defmodule Flow.IFTTT do
  require Logger

  @headers [{"accept", "application/json"}]
  def trigger(action) do
    :post
    |> Finch.build(ifttt_url(action), @headers)
    |> Finch.request(FlowFinch)
    |> parse_response()
  end

  defp ifttt_url(action) do
    key = config(:ifttt_key)
    "https://maker.ifttt.com/trigger/#{action}/with/key/#{key}"
  end

  @spec parse_response({:ok, Finch.Response.t()} | {:error, Mint.Types.error()}) :: :ok

  defp parse_response({:ok, %Finch.Response{} = response}) do
    case response.status do
      200 ->
        :ok

      status ->
        Sentry.capture_message(
          "ifttt_bad_response_status",
          extra: %{
            message: "Expected 200, got #{status}",
            response: response
          }
        )

        message = "Expected IFTTT to return status 200, but got #{status}.
            Reponse was: #{inspect(response)}"
        Logger.error(message)
        :ok
    end
  end

  defp parse_response(response_tuple) do
    Sentry.capture_message(
      "ifttt_bad_response",
      extra: %{
        message: "Expected {:ok, response} tuple",
        response: response_tuple
      }
    )

    message =
      "Expected {:ok, response} tuple from IFTTT, but got" <>
        "#{inspect(response_tuple)}"

    Logger.error(message)
    :ok
  end

  defp config(key) do
    :flow |> Application.fetch_env!(:humidity) |> Keyword.fetch!(key)
  end
end
