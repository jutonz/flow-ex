defmodule Homepage.Client do
  require Logger
  alias Homepage.Request

  @spec make_request(Request.t()) ::
    {:ok, String.t()} |
    {:ok, map()} |
    {:error, :bad_response}
  def make_request(%Request{} = request) do
    request
    |> build_request()
    |> execute()
    |> respond()
  end

  @api_base "https://app.jutonz.com"
  defp build_request(%Request{} = request) do
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

  defp respond({:ok, %Finch.Response{body: body} = response}) do
    case content_type(response) do
      :json -> {:ok, Jason.decode!(body)}
      :text -> {:ok, body}
    end
  end

  defp respond(response) do
    Logger.warn("Received bad response from homepage #{inspect(response)}")
    {:error, :bad_response}
  end

  defp encode_body(nil) do
    nil
  end

  defp encode_body(json) do
    Jason.encode!(json)
  end

  defp content_type(%Finch.Response{} = response) do
    case get_header(response, "content-type") do
      "application/json" -> :json
      _ -> :text
    end
  end

  defp get_header(%Finch.Response{headers: headers}, header) do
    case List.keyfind(headers, header, 0) do
      {_header, value} -> value
      _ -> nil
    end
  end
end
