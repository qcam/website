defmodule HQC.Web.RouteHelper do
  @base_url :hqc
            |> Application.fetch_env!(:web)
            |> Keyword.fetch!(:base_url)

  def prepend_base(path), do: @base_url <> path

  def root_path(), do: "/"

  def root_url() do
    root_path() |> prepend_base()
  end

  def page_path(slug) do
    root_path() <> slug
  end

  def page_url(slug) do
    slug
    |> page_path()
    |> prepend_base()
  end

  def news_path(), do: "/news"

  def news_path(params) when params == %{}, do: news_path()

  def news_path(%{"page" => 1} = params) do
    params
    |> Map.delete("page")
    |> news_path()
  end

  def news_path(%{"category" => nil} = params) do
    params
    |> Map.delete("category")
    |> news_path()
  end

  def news_path(params) when is_map(params) do
    news_path() <> "?" <> Plug.Conn.Query.encode(params)
  end
end
