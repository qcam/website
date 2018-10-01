defmodule HQC.PostRepo do
  use Nabo.Repo,
    root: "priv/posts",
    compiler: [
      body_parser: {Nabo.Parser.Markdown, %Earmark.Options{code_class_prefix: "lang-"}}
    ]
end
