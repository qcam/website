defmodule HQC.Reader.News do
  @enforce_keys [
    :id,
    :title,
    :url,
    :published_at,
    :category,
    :source,
    :description
  ]

  defstruct @enforce_keys

  def new(%Fiet.Item{} = item, source, category) do
    case parse_datetime(item.published_at) do
      {:ok, published_at} ->
        {:ok,
         %__MODULE__{
           id: item.id || hash(item.url),
           title: item.title,
           source: source,
           category: category,
           url: item.link,
           published_at: published_at,
           description: item.description
         }}

      :error ->
        :error
    end
  end

  def sort_by_recency(news_list) do
    Enum.sort(news_list, &(NaiveDateTime.compare(&1.published_at, &2.published_at) == :gt))
  end

  def filter_by_category(news_list, category) when is_binary(category) do
    Enum.filter(news_list, &(&1.category == category))
  end

  def search_by_source(news_list, source) when is_binary(source) do
    Enum.filter(news_list, &(&1.source == source))
  end

  def map_categories(news_list) do
    news_list
    |> Enum.map(& &1.category)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp hash(url) when is_binary(url) do
    :crypto.hash(:sha256, url)
  end

  defp parse_datetime(string) do
    case RFC2822.from_string(string) do
      {:ok, datetime} ->
        {:ok, datetime}

      {:error, :invalid} ->
        case DateTime.from_iso8601(string) do
          {:error, _reason} ->
            :error

          {:ok, datetime, utc_offset} ->
            datetime =
              datetime
              |> DateTime.to_naive()
              |> NaiveDateTime.add(-utc_offset)

            {:ok, datetime}
        end
    end
  end
end
