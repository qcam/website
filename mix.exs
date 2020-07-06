defmodule HQC.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :hqc,
      version: "0.8.4",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application() do
    [
      mod: {HQC, []},
      extra_applications: [:logger]
    ]
  end

  defp deps() do
    [
      {:nabo, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:earmark, "~> 1.2.5"},
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.4"},
      {:hackney, "~> 1.15.0"},
      {:fiet, "~> 0.3"},
      {:saxy, "~> 1.2"},
      {:nimble_parsec, "~> 0.3.2", runtime: false}
    ]
  end
end
