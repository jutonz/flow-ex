defmodule DigitalOcean.Client do
  require Logger
  alias DigitalOcean.Request

  @spec make_request(Request.t()) ::
    {:ok, map()} |
    {:error, :bad_response} |
    {:error, :unauthorized}
  def make_request(%Request{} = request) do
    request
    |> build_request()
    |> execute()
    |> respond()
  end

  @api_base "https://api.digitalocean.com"
  def build_request(%Request{} = request) do
    Finch.build(
      request.method,
      @api_base <> request.path,
      Map.to_list(request.headers),
      encode_body(request.body)
    )
  end

  @timeout 5_000
  def execute(request) do
    Finch.request(request, FlowFinch, receive_timeout: @timeout)
  end

  defp respond({:ok, %Finch.Response{body: body, status: status} = response}) do
    case status do
      401 ->
        {:error, :unauthorized}
      status when status >= 100 and status < 300 ->
        {:ok, Jason.decode!(body)}
      _ ->
      Logger.warn("Received bad response from digitalocean #{inspect(response)}")
        {:error, :bad_response}
    end
  end

  defp respond(response) do
    Logger.warn("Received bad response from digitalocean #{inspect(response)}")
    {:error, :bad_response}
  end

  defp encode_body(nil),
    do: nil

  defp encode_body(json),
    do: Jason.encode!(json)
end
