defmodule HQC.Reader.Supervisor do
  use DynamicSupervisor

  alias HQC.Reader

  require Logger

  def start_link(options) do
    {:ok, _pid} = Registry.start_link(keys: :unique, name: Reader.Registry)

    DynamicSupervisor.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init(options) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [options])
  end

  def start_child(options) do
    child_spec = %{
      id: nil,
      start: {Reader.Feed, :start_link, [options]},
      restart: :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, child_spec) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        :ok

      other ->
        Logger.error(
          "Failed to start feed fetcher, struct: #{inspect(options)}, reason: #{inspect(other)}"
        )

        other
    end
  end
end
