defmodule Flow.MixProject do
  use Mix.Project

  def project do
    [
      app: :flow,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Flow.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_gpio, "~> 0.4"},
      {:erlport, "~> 0.10.1"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:phoenix_gen_socket_client, "~> 3.0.0"},
      {:websocket_client, "~> 1.2"}
    ]
  end
end
