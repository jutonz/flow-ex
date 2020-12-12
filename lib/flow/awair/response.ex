defmodule Flow.Awair.Response do
  @type t :: %__MODULE__{
          humidity: float(),
          raw_response: Finch.Response.t()
        }

  defstruct humidity: nil,
            raw_response: nil
end
