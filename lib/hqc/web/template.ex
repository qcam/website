defmodule HQC.Web.Template do
  require EEx

  defmacro __using__(options) do
    quote bind_quoted: [options: options],
          unquote: true do
      @root options |> Keyword.fetch!(:root) |> Path.relative_to_cwd()

      @before_compile unquote(__MODULE__)

      def render_template(template, assigns \\ [])
    end
  end

  defmacro __before_compile__(env) do
    root = Module.get_attribute(env.module, :root)
    pattern = "**/*"

    pairs =
      for path <- find_all(root, pattern) do
        compile(path, root)
      end

    {names, codes} = Enum.unzip(pairs)

    quote generated: true do
      unquote(codes)

      def available_templates() do
        unquote(names)
      end
    end
  end

  defp compile(path, root) do
    name = template_name(path, root)
    quoted = EEx.compile_file(path, line: 1, trim: true)

    {name,
     quote do
       @file unquote(path)
       @external_resource unquote(path)

       def render_template(unquote(name), var!(assigns)) do
         var!(assigns)

         unquote(quoted)
       end
     end}
  end

  defp find_all(root, pattern) do
    root
    |> Path.join(pattern <> ".eex")
    |> Path.wildcard()
  end

  defp template_name(path, root) do
    path
    |> Path.rootname()
    |> Path.relative_to(root)
  end
end
