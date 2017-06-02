defmodule HQC do
  use Application

  def start(_type, _args) do
    cowboy_config = Application.fetch_env!(:hqc, :cowboy)

    options = []

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, HQC.Router, [], cowboy_config),
      %{
        id: HQC.Reader,
        start: {HQC.Reader, :start_link, [options]}
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
