defmodule Flow.Api do
  def upload(log_id, ml) do
    HTTPoison.post!(
      log_entries_path(log_id),
      Jason.encode!(%{"ml" => ml}),
      [
        {"authorization", "Bearer #{api_token()}"},
        {"content-type", "application/json"}
      ]
    )
  end

  @api_path "https://app.jutonz.com/api/water-logs/:log_id/entries"
  defp log_entries_path(log_id),
    do: String.replace(@api_path, ":log_id", log_id)

  defp api_token,
    do: Application.fetch_env!(:flow, :api_key)
end
