defmodule Qcam.WebApp.Template do
  defmacro __using__(options) do
    quote bind_quoted: [options: options], unquote: true do
      @root Keyword.fetch!(options, :root) |> Path.relative_to_cwd

      @before_compile unquote(__MODULE__)

      def render_tmpl(template, assigns \\ %{})
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    root    = Module.get_attribute(env.module, :root)
    pattern = "**/*"

    pairs = for path <- find_all(root, pattern) do
      compile(path, root)
    end

    names = Enum.map(pairs, &elem(&1, 0))
    codes = Enum.map(pairs, &elem(&1, 1))

    quote [generated: true] do
      unquote(codes)

      def render_tmpl(template, assigns) do
        render_template(template, assigns)
      end

      def available_templates do
        unquote(names)
      end
    end
  end

  def find_all(root, pattern) do
    root
    |> Path.join(pattern <> ".eex")
    |> Path.wildcard()
  end

  def template_path_to_name(path, root) do
    path
    |> Path.rootname()
    |> Path.relative_to(root)
  end

  defp compile(path, root) do
    name   = template_path_to_name(path, root)

    defp   = String.to_atom(name)
    quoted = EEx.compile_file(path, line: 1, trim: true)

    {name, quote do
      @file unquote(path)
      @external_resource unquote(path)

      defp unquote(defp)(var!(assigns)) do
        _ = var!(assigns)
        unquote(quoted)
      end

      defp render_template(unquote(name), assigns) do
        unquote(defp)(assigns)
      end
    end}
  end
end
