defmodule Conduit.Blog do
  import Ecto.Query, warn: false

  alias Conduit.Repo

  alias Conduit.Account.{User, UserFollower}
  alias Conduit.Blog.{Article}

  # article CURD

  def create_article(attrs, user) do
    attrs = Map.put(attrs, :author_id, user.id)

    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, article} -> {:ok, Repo.preload(article, :author)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_article_by_slug(titled_slug) do
    [slug | _] = String.split(titled_slug, "-")

    Repo.get_by(Article, slug: slug)
    |> Repo.preload(:author)
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
end
