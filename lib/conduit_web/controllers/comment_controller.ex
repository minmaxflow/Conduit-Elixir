defmodule ConduitWeb.CommentController do
  use ConduitWeb, :controller

  alias Conduit.Blog

  action_fallback ConduitWeb.FallbackController

  def index(conn, %{"slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)
    comments = Blog.list_comment(slug, user)
    render(conn, "index.json", comments: comments)
  end

  def create(conn, %{"slug" => slug, "comment" => comment_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, comment} <- Blog.create_comment(slug, comment_params, user) do
      render(conn, "show.json", comment: comment)
    end
  end

  def delete(conn, %{"slug" => slug, "id" => comment_id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, comment} <- Blog.delete_comment(slug, comment_id, user) do
      render(conn, "show.json", comment: comment)
    end
  end
end
