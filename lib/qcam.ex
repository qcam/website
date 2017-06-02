defmodule Qcam do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Qcam.WebApp, [], port: 8080),
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
