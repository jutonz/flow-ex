defmodule Flow.IFTTT do
  require Logger

  def trigger(action) do
    :post
    |> Finch.build(ifttt_url(action))
    |> Finch.request(FlowFinch)
    |> parse_response()
  end

  defp ifttt_url(action) do
    key = Application.fetch_env!(:flow, :humidity)[:ifttt_key]
    "https://maker.ifttt.com/trigger/#{action}/with/key/#{key}"
  end

  @spec parse_response({:ok, Finch.Response.t()} | {:error, Mint.Types.error()}) :: :ok

  defp parse_response({:ok, %Finch.Response{} = response}) do
    case response.status do
      200 ->
        :ok

      status ->
        # TODO: Send to Sentry
        message = "Expected IFTTT to return status 200, but got #{status}.
            Reponse was: #{inspect(response)}"
        Logger.error(message)
        :ok
    end
  end

  defp parse_response(response_tuple) do
    # TODO: Send to Sentry
    message =
      "Expected {:ok, response} tuple from IFTTT, but got" <>
        "#{inspect(response_tuple)}"

    Logger.error(message)
    :ok
  end
end
