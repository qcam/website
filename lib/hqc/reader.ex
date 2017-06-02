defmodule HQC.Reader do
  use GenServer

  alias HQC.Reader

  require Logger

  @gist_id :hqc
           |> Application.fetch_env!(__MODULE__)
           |> Keyword.fetch!(:gist_id)

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init(options) do
    __MODULE__.Supervisor.start_link(options)
    __MODULE__.Vault.start_link()

    schedule_import(interval: 0)

    {:ok, []}
  end

  def get_news() do
    __MODULE__.Vault.all()
  end

  def handle_info(:import, feeds) do
    schedule_import(interval: _two_minutes = 120_000)

    case fetch_gist(@gist_id) do
      {:ok, feeds} ->
        spawned_feeds =
          Enum.flat_map(feeds, fn payload ->
            with {:ok, feed} <- Reader.Feed.new(payload),
                 :ok <- Reader.Supervisor.start_child(feed) do
              [feed]
            else
              _other -> []
            end
          end)

        {:noreply, spawned_feeds}

      :error ->
        {:noreply, feeds}
    end
  end

  defp fetch_gist(gist_id) do
    req_url = "https://api.github.com/gists/" <> gist_id

    req_options = [
      :with_body,
      recv_timeout: 5_000
    ]

    case :hackney.request(:get, req_url, [], [], req_options) do
      {:ok, 200, _resp_headers, resp_body} ->
        feeds =
          resp_body
          |> Jason.decode!()
          |> get_in(["files", "feed_subscriptions.json", "content"])
          |> Jason.decode!()

        {:ok, feeds}

      {:ok, status_code, _resp_headers, _resp_body} ->
        Logger.error("Unexpected Github API response, status: #{inspect(status_code)}")
        :error

      {:error, reason} ->
        Logger.error("Unable to reach Github API, reason: #{inspect(reason)}")
        :error
    end
  end

  defp schedule_import(options) do
    interval = Keyword.fetch!(options, :interval)
    Process.send_after(self(), :import, interval)
  end
end
