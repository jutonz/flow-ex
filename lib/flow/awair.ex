defmodule Flow.Awair do
  require Logger
  alias Flow.Awair.Response

  def humidity(ip) do
    case current_values(ip) do
      {:ok, %Response{humidity: humidity}} -> {:ok, humidity}
      error -> error
    end
  end

  def current_values(ip) do
    :get
    |> Finch.build("http://#{ip}/air-data/latest")
    |> request()
    |> parse_response()
  end

  @type response ::
          {:ok, Flow.Awair.Response.t()}
          | {:error, :bad_response}
          | {:error, {:invalid_json_response, String.t()}}

  @spec parse_response({:ok, Finch.Response.t()} | {:error, Mint.Types.error()}) :: response()

  defp parse_response({:ok, %Finch.Response{} = response}) do
    case Jason.decode(response.body) do
      {:ok, data} ->
        {:ok,
         %Flow.Awair.Response{
           humidity: data["humid"],
           raw_response: response
         }}

      {:error, _reason} ->
        {:error, {:invalid_json_response, response.body}}
    end
  end

  defp parse_response(response) do
    Logger.warn("Received bad response from awair #{inspect(response)}")
    {:error, :bad_response}
  end

  @timeout 5_000
  defp request(request) do
    Finch.request(request, FlowFinch, receive_timeout: @timeout)
  end
end
