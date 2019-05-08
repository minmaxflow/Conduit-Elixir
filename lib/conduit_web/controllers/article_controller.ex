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
    user = Guardian.Plug.current_resource(conn)

    with {:ok, article} <- Blog.get_article_by_slug(slug, user) do
      render(conn, "show.json", article: article)
    end
  end

  def update(conn, %{"slug" => slug, "article" => article_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %Article{} = article} <- Blog.update_article(slug, article_params, user) do
      render(conn, "show.json", article: article)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    with {:ok, %Article{} = article} <- Blog.delete_article_by_slug(slug) do
      render(conn, "delete.json", article: article)
    end
  end

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    articles = Blog.list_articles(params, user)
    render(conn, "index.json", articles: articles)
  end

  def feed(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    articles = Blog.list_articles_feed(params, user)
    render(conn, "index.json", articles: articles)
  end

  def favorite(conn, %{"slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, article} <- Blog.favorite(slug, user) do
      render(conn, "show.json", article: article)
    end
  end

  def unfavorite(conn, %{"slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, article} <- Blog.un_favorite(slug, user) do
      render(conn, "show.json", article: article)
    end
  end
end
