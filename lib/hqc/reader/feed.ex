defmodule HQC.Reader.Feed do
  use GenServer

  alias HQC.Reader

  require Logger

  @enforce_keys [
    :source,
    :url,
    :category
  ]

  defstruct @enforce_keys

  def start_link(_supervisor_options, %__MODULE__{} = feed) do
    start_options = [name: {:via, Registry, {Reader.Registry, feed.source}}]

    GenServer.start_link(__MODULE__, feed, start_options)
  end

  def new(payload) do
    with {:ok, source} <- Map.fetch(payload, "source"),
         {:ok, url} <- Map.fetch(payload, "url"),
         {:ok, category} <- Map.fetch(payload, "category") do
      {:ok,
       %__MODULE__{
         source: source,
         url: url,
         category: category
       }}
    else
      :error -> :error
    end
  end

  def init(feed) do
    schedule_fetch(interval: 0)

    {:ok, {feed, _last_etag = nil}}
  end

  def handle_info(:import, {struct, last_etag} = state) do
    %__MODULE__{
      source: source,
      url: url,
      category: category
    } = struct

    schedule_fetch(interval: Enum.random(1_800..3_600))

    case fetch_feed(url, last_etag) do
      {:ok, :not_modified} ->
        {:noreply, state}

      {:ok, {new_etag, body}} ->
        case parse_feed(body, source, category) do
          {:ok, items} ->
            Enum.each(items, &Reader.Vault.insert/1)
            {:noreply, {struct, new_etag}}

          {:error, reason} ->
            Logger.error(
              "unexpected error when parsing feed (source: #{source}), reason: #{inspect(reason)}"
            )

            {:noreply, state}
        end

      :error ->
        {:noreply, state}
    end
  end

  defp fetch_feed(url, last_etag) do
    req_headers = maybe_put_etag([], last_etag)

    req_options = [
      recv_timeout: 5_000
    ]

    case :hackney.get(url, req_headers, [], req_options) do
      {:ok, 304, _, ref} ->
        :ok = :hackney.skip_body(ref)
        {:ok, :not_modified}

      {:ok, 200, resp_headers, ref} ->
        with etag = find_header(resp_headers, "etag"),
             {:ok, body} <- :hackney.body(ref) do
          {:ok, {etag, body}}
        else
          {:error, reason} ->
            Logger.error(
              "Unable to read response body, url: #{inspect(url)}, reason: #{inspect(reason)}"
            )

            :error
        end

      {:ok, status, _resp_headers, ref} ->
        :ok = :hackney.skip_body(ref)
        Logger.error("Unexpected response, status: #{inspect(status)}, URL: #{inspect(url)}")
        :error

      {:error, reason} ->
        Logger.error("Unable to reach host, reason: #{inspect(reason)}")
        :error
    end
  end

  defp schedule_fetch(options) do
    interval = Keyword.fetch!(options, :interval)

    Process.send_after(self(), :import, interval)
  end

  defp find_header(headers, name) do
    case Enum.find(headers, fn {key, _} -> key == name end) do
      {_, value} -> value
      nil -> nil
    end
  end

  defp maybe_put_etag(headers, nil), do: headers
  defp maybe_put_etag(headers, etag), do: [{"if-none-match", etag} | headers]

  defp parse_feed(body, source, category) do
    case Fiet.parse(body) do
      {:ok, feed} ->
        items =
          Enum.flat_map(feed.items, fn item ->
            case Reader.News.new(item, source, category) do
              {:ok, news} ->
                [news]

              :error ->
                Logger.debug("Unable to build news struct from item: #{inspect(item)}")
                []
            end
          end)

        {:ok, items}

      :error ->
        Logger.error("Unable to parse feed, feed body: #{inspect(body)}")
        :error
    end
  end
end
