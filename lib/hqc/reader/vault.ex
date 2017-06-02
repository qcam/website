defmodule HQC.Reader.Vault do
  require Logger

  alias HQC.Reader.News

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: __MODULE__)
  end

  def init(_options) do
    table = :ets.new(__MODULE__, [:public, :named_table, read_concurrency: true])

    {:ok, table}
  end

  def insert(%News{} = news) do
    :ets.insert(__MODULE__, {news.id, news})
  end

  def all() do
    __MODULE__
    |> :ets.match_object({:"$1", :_})
    |> Enum.map(&elem(&1, 1))
  end
end
