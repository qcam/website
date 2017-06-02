defmodule HQC.Web.View do
  require EEx

  use HQC.Web.Template, root: "lib/hqc/web/templates"

  alias HQC.Web.{
    RouteHelper
  }

  alias HQC.Paginator.Page

  def render(template, assigns) do
    {layout, assigns} = Keyword.pop(assigns, :layout, "default")
    body = render_template(template, assigns)
    assigns = Keyword.put(assigns, :body, body)

    render_template(layout, assigns)
  end

  def render_static(page_body, assigns) do
    assigns = Keyword.put(assigns, :body, page_body)

    render_template("static", assigns)
  end

  defp web_title(""), do: "HQC.IO | Cẩm Huỳnh's website"
  defp web_title(title), do: title
end
