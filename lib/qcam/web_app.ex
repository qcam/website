defmodule Qcam.WebApp do
  use Plug.Router

  alias Qcam.WebApp.View
  alias Qcam.Repo

  plug Plug.Logger
  plug Plug.Static, at: "/assets", from: "priv/static/dist"
  plug :match
  plug :dispatch

  get "/" do
    render(conn, View.render("index", layout: "home"))
  end

  get "/posts"  do
    {:ok, posts} = Repo.all()
    {page_number, _} = conn
                       |> fetch_query_params()
                       |> Map.fetch!(:params)
                       |> Map.get("page", "1")
                       |> Integer.parse()
    page = Scrivener.paginate(posts, %Scrivener.Config{page_number: page_number, page_size: 5})

    if page.page_number <= page.total_pages do
      assigns = [
        page_title: "Writtings",
        posts: page.entries,
        previous_page?: page.page_number > 1,
        next_page?: page.page_number < page.total_pages,
        previous_page: page.page_number - 1,
        next_page: page.page_number + 1,
      ]
      body = View.render("posts/index", assigns)
      render(conn, body)
    else
      not_found!(conn)
    end
  end

  get "/posts/:slug" do
    case Repo.get(slug) do
      {:ok, %Nabo.Post{} = post} ->
        render(conn, View.render("posts/show", page_title: post.title, post: post))
      _ ->
        not_found!(conn)
    end
  end

  get "/tags/:tag" do
    posts = Repo.by_tag(tag)
    body = View.render("tags/index", page_title: "##{tag}", posts: posts)

    render(conn, body)
  end

  get "/about" do
    conn
    |> render(View.render_static("about", page_title: "About me"))
  end

  get "/friends" do
    conn
    |> render(View.render_static("friends", page_title: "Friends"))
  end

  # Old posts redirection
  get "/essays", do: redirect!(conn, "/posts", status: 301)

  get "/:year/:month/:day/:slug" do
    slug = slug |> String.split(".") |> Enum.at(0)

    redirect!(conn, "/posts/#{slug}", status: 301)
  end

  match _, do: not_found!(conn)

  defp render(conn, :not_found) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(404, "Not found")
  end

  defp render(conn, body) do
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, body)
  end

  def not_found!(conn) do
    render(conn, :not_found)
  end

  defp redirect!(conn, to, opts) do
    status = Keyword.get(opts, :status, 302)

    conn
    |> Plug.Conn.put_resp_header("location", to)
    |> send_resp(status, "You're being redirected")
  end
end
