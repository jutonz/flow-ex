defmodule Homepage.ClientInfo do
  alias Homepage.{Client, Request}

  def whatismyip do
    "/api/whatismyip"
    |> Request.new(:get)
    |> Client.make_request()
    |> respond()
  end

  defp respond({:ok, ip}) do
    {:ok, ip}
  end

  defp respond(error) do
    error
  end
end
