defmodule DigitalOcean do
  defdelegate get_domain_record(domain_name, record_id),
    to: __MODULE__.Domains

  defdelegate update_domain_record(domain_name, record_id, body),
    to: __MODULE__.Domains
end
