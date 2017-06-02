use Mix.Config

config :logger, backends: [:console]

config :hqc, :cowboy, port: "PORT" |> System.get_env() |> String.to_integer()

config :hqc, :web, base_url: "https://hqc.io"
