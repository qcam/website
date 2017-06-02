defmodule Qcam.WebApp.View do
  require EEx
  use Qcam.WebApp.Template, root: "lib/qcam/web_app/templates"

  @page_path "priv/_pages/"

  def render(template, assigns) do
    {layout, assigns} = Keyword.pop(assigns, :layout, "default")

    body = render_tmpl(template, assigns)
    page_title = Keyword.get(assigns, :page_title, "Qcam")

    render_within_layout(layout, page_title: page_title, body: body)
  end

  def render_static(page, assigns) do
    body = File.read!(@page_path <> page <> ".md") |> Earmark.as_html!()
    page_title = Keyword.fetch!(assigns, :page_title)

    render_within_layout("static", page_title: page_title, body: body)
  end

  def render_within_layout(layout, assigns) do
    page_title = Keyword.fetch!(assigns, :page_title)
    body = Keyword.fetch!(assigns, :body)

    render_tmpl(layout, page_title: page_title, body: body)
  end

  defp web_title(title), do: "hqc.io | #{title}"
end
