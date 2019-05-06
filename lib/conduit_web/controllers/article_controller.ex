defmodule ConduitWeb.ArticleController do
  use ConduitWeb, :controller

  alias Conduit.Blog
  alias Conduit.Blog.Article

  action_fallback ConduitWeb.FallbackController

  def create(conn, %{"article" => article_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Article{} = article} <- Blog.create_article(article_params, user) do
      conn
      |> put_status(:created)
      |> render("show.json", article: article)
    end
  end

  def show(conn, %{"slug" => slug}) do
    with {:ok, article} <- Blog.get_article_by_slug(slug) do
      render(conn, "show.json", article: article)
    end
  end

  def update(conn, %{"slug" => slug, "article" => article_params}) do
    with {:ok, %Article{} = article} <- Blog.update_article(slug, article_params) do
      render(conn, "show.json", article: article)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    with {:ok, %Article{} = article} <- Blog.delete_article_by_slug(slug) do
      render(conn, "delete.json", article: article)
    end
  end
end
