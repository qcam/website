defmodule Qcam.Mixfile do
  use Mix.Project

  def project do
    [app: :qcam,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [
      mod: {Qcam, []},
      extra_applications: [:logger, :cowboy, :plug, :scrivener],
    ]
  end

  defp deps do
    [
      {:nabo, "~> 0.0.1", github: "qcam/nabo"},
      {:cowboy, "~> 1.1.2"},
      {:plug, "~> 1.3.4"},
      {:scrivener, "~> 2.0"},
      {:scrivener_list, "~> 1.0"},
    ]
  end
end
