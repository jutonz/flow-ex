defmodule Homepage.Request do
  defstruct [
    path: nil,
    method: nil,
    headers: %{},
    body: nil,
  ]

  def new(path, method) do
    %__MODULE__{path: path, method: method}
  end
end
