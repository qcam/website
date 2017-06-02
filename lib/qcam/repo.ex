defmodule Qcam.Repo do
  use Nabo.Repo, root: "priv/_posts"

  def by_tag(tag) do
    case all() do
      {:ok, posts} ->
        posts
        |> Enum.filter(& Enum.member?(&1.metadata["tags"], tag))
      _ ->
        {:error, "Failed to fetch posts"}
    end
  end
end
