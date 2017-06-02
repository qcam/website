defmodule HQC.Router do
  use Plug.Router

  alias HQC.Web.{
    View,
    Metadata,
    RouteHelper
  }

  alias HQC.{
    PageRepo,
    Paginator,
    Reader
  }

  plug(Plug.Static, at: "/assets", from: "priv/static/dist")

  plug(Plug.Logger, log: :debug)

  plug(Plug.Parsers, parsers: [:urlencoded])

  plug(:match)
  plug(:dispatch)

  get "/" do
    posts =
      Reader.Vault.all()
      |> Reader.News.search_by_source("quan-cam.com")
      |> Reader.News.sort_by_recency()
      |> Enum.take(5)

    journals =
      Reader.Vault.all()
      |> Reader.News.search_by_source("medium.com/@hqc")
      |> Reader.News.sort_by_recency()
      |> Enum.take(5)

    metadata = %Metadata{
      title: "HQC.IO | Cẩm Huỳnh's website",
      description:
        "Hey, it is Cẩm, I write and note down everything spinning around my life in this blog.",
      keywords: ["blog", "programming", "web", "software development"],
      type: "website",
      current_path: RouteHelper.root_path(),
      current_url: RouteHelper.root_url()
    }

    send_html_resp(
      conn,
      View.render("index", layout: "home", metadata: metadata, posts: posts, journals: journals)
    )
  end

  @news_page_size 10

  get "/news" do
    category = Map.get(conn.params, "category")

    news_entries = Reader.get_news()

    categories = Reader.News.map_categories(news_entries)

    page_number =
      conn.params
      |> Map.get("page", "1")
      |> String.to_integer(10)

    page =
      news_entries
      |> maybe_filter_by_category(category)
      |> Reader.News.sort_by_recency()
      |> Paginator.paginate(page_number, @news_page_size)

    metadata = %Metadata{
      title: format_category(category),
      description: "HQC's feed reader",
      keywords: [],
      type: "website",
      current_path: RouteHelper.root_path(),
      current_url: RouteHelper.root_url()
    }

    if page.page_number <= page.page_count do
      assigns = [
        metadata: metadata,
        categories: categories,
        category: category,
        page: page
      ]

      body = View.render("news/index", assigns)

      send_html_resp(conn, body)
    else
      render_not_found(conn)
    end
  end

  get "/about" do
    %Nabo.Post{body_html: page_body} = PageRepo.get!("about")

    current_path = RouteHelper.page_path("about")
    current_url = RouteHelper.page_url("about")

    metadata = %Metadata{
      title: "About Cẩm Huỳnh",
      description: "Everything you may want to know about Cẩm",
      type: "profile",
      keywords: ["about"],
      current_path: current_path,
      current_url: current_url
    }

    send_html_resp(conn, View.render_static(page_body, metadata: metadata))
  end

  match(_, do: render_not_found(conn))

  defp render_not_found(conn) do
    metadata = %Metadata{
      title: "404 Not Found",
      description: "404 Not Found",
      type: "website",
      keywords: [],
      current_path: RouteHelper.root_url(),
      current_url: RouteHelper.root_url()
    }

    body = View.render_template("not_found", metadata: metadata)

    send_html_resp(conn, 404, body)
  end

  defp send_html_resp(conn, status \\ 200, body) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(status, body)
  end

  defp maybe_filter_by_category(entries, nil), do: entries

  defp maybe_filter_by_category(entries, category) do
    Reader.News.filter_by_category(entries, category)
  end

  defp format_category(nil), do: "#everything"
  defp format_category(category), do: "#" <> category
end
