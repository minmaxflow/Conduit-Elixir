defmodule Conduit.Blog do
  import Ecto.Query, warn: false

  alias Conduit.Repo

  alias Conduit.Account.{User, UserFollower}
  alias Conduit.Blog.{Article, Favorite}

  # article CURD

  def create_article(attrs, user) do
    attrs = Map.put(attrs, :author_id, user.id)

    attrs = for {k, v} <- attrs, do: {to_string(k), v}, into: %{}

    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, article} -> {:ok, Repo.preload(article, :author)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_article_by_slug(titled_slug, user) do
    [slug | _] = String.split(titled_slug, "-")

    case Repo.get_by(Article, slug: slug) do
      nil -> {:error, :not_found}
      article -> {:ok, Repo.preload(article, :author)}
    end
  end

  def delete_article_by_slug(titled_slug) do
    [slug | _] = String.split(titled_slug, "-")

    case Repo.get_by(Article, slug: slug) do
      nil -> {:error, :not_found}
      article -> Repo.delete(article)
    end
  end

  def update_article(titled_slug, attrs) do
    [slug | _] = String.split(titled_slug, "-")

    with article when not is_nil(article) <- Repo.get_by(Article, slug: slug) do
      article
      |> Article.changeset(attrs)
      |> Repo.update()
      |> case do
        {:ok, article} -> {:ok, Repo.preload(article, :author)}
        {:error, changeset} -> {:error, changeset}
      end
    else
      nil -> {:error, :not_found}
    end
  end

  # article favorite

  def favorite(slug, user) do
    with {:ok, article} <- get_article_by_slug(slug, user),
         {:ok, favorite} <-
           %Favorite{}
           |> Favorite.changeset(%{user_id: user.id, article_id: article.id})
           |> Repo.insert() do
      get_article_by_slug(slug, user)
    end
  end

  def un_favorite(slug, user) do
    with {:ok, article} <- get_article_by_slug(slug, user) do
      case Repo.get_by(Favorite, user_id: user.id, article_id: article.id) do
        nil ->
          {:error, :not_found}

        favorite ->
          Repo.delete(favorite)
          get_article_by_slug(slug, user)
      end
    end
  end
end
