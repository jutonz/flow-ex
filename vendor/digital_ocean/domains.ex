defmodule DigitalOcean.Domains do
  alias DigitalOcean.{Client, Request}

  @path "/v2/domains"

  def get_domain_record(domain_name, record_id) do
    @path <> "/#{domain_name}/records/#{record_id}"
    |> Request.new(:get)
    |> Request.authorize()
    |> Client.make_request()
    |> respond()
  end

  def update_domain_record(domain_name, record_id, body) do
    @path <> "/#{domain_name}/records/#{record_id}"
    |> Request.new(:put)
    |> Request.authorize()
    |> Request.put_header("content-type", "application/json")
    |> Request.put_body(body)
    |> Client.make_request()
    |> respond()
  end

  defp respond({:ok, response}) do
    {:ok, Map.get(response, "domain_record")}
  end

  defp respond(error) do
    error
  end
end
