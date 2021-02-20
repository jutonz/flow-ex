defmodule DigitalOcean.Request do
  defstruct [
    path: nil,
    method: nil,
    headers: %{},
    body: nil,
  ]


  def new(path, method) do
    %__MODULE__{path: path, method: method}
  end

  def put_header(request, key, value) do
    %{request | headers: Map.put(request.headers, key, value)}
  end

  def put_body(request, body) do
    %{request | body: body}
  end

  def authorize(request) do
    put_header(request, "authorization", "Bearer #{config(:api_token)}")
  end

  defp config(key) do
    :flow |> Application.fetch_env!(:digital_ocean) |> Keyword.fetch!(key)
  end
end
