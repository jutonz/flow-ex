defmodule Flow.DomainUpdater do
  require Logger
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    if disabled?() do
      Logger.info("No DigitalOcean API key configured. Skipping DomainUpdater.")
      :ignore
    else
      initial_state = %{
        domain: config(:domain),
        record_id: config(:record_id)
      }

      {:ok, initial_state, {:continue, nil}}
    end
  end

  def handle_continue(nil, state) do
    schedule_checkin()
    {:noreply, state}
  end

  @check_every 1000 * 60 * 60
  defp schedule_checkin do
    Process.send_after(self(), :update_domain, @check_every)
  end

  def handle_info(:update_domain, state) do
    with {:ok, ip} <- Homepage.whatismyip(),
         {:ok, domain_record} <- update_domain_record(state, ip) do
      Logger.info("Updated domain record: #{inspect(domain_record)}")
    else
      error ->
        Logger.warn("An error occurred updating the domain: #{inspect(error)}")
    end

    schedule_checkin()
    {:noreply, state}
  end

  defp update_domain_record(%{domain: domain, record_id: record_id}, ip) do
    DigitalOcean.update_domain_record(domain, record_id, %{"data" => ip})
  end

  defp disabled? do
    token = config(:api_token)
    token == nil || token == ""
  end

  defp config(config) do
    Application.fetch_env!(:flow, :digital_ocean) |> Keyword.fetch!(config)
  end
end
