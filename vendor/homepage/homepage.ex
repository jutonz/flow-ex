defmodule Homepage do
  defdelegate whatismyip,
    to: __MODULE__.ClientInfo
end
