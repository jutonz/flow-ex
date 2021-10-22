defmodule Flow.MixProject do
  use Mix.Project

  def project do
    [
      app: :flow,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_apps: ~w[mix]a,
        plt_core_path: "_plts",
        plt_file: {:no_warn, "_plts/app.plt"}
      ],
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        # For http requests to awair/ifttt
        :inets,
        # For https requests to ifttt
        :ssl
      ],
      mod: {Flow.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_gpio, "~> 0.4"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:erlport, "~> 0.10.1"},
      {:finch, "~> 0.9.0"},
      {:hackney, "~> 1.8"},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:phoenix_gen_socket_client, "~> 3.2.1"},
      {:sentry, "8.0.5"},
      {:websocket_client, "~> 1.4.2"}
    ]
  end

  def aliases do
    [
      dialyzer: ["dialyzer_pre", "dialyzer"]
    ]
  end
end
