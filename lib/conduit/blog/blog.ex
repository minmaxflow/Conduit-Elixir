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
      {:ok, article} -> get_article_by_slug(article.slug, user)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_article_by_slug(titled_slug, user) do
    [slug | _] = String.split(titled_slug, "-")

    uid =
      case user do
        nil -> -1
        user -> user.id
      end

    # 参考 
    # https://stackoverflow.com/questions/33784786/how-to-check-if-value-exists-in-each-group-after-group-by
    # https://dev.mysql.com/doc/refman/5.7/en/group-by-functional-dependence.html
    # https://gabi.dev/2016/03/03/group-by-are-you-sure-you-know-it/
    query =
      from a in Article,
        left_join: f in Favorite,
        on: a.id == f.article_id,
        where: a.slug == ^slug,
        group_by: a.id,
        select: %{
          a
          | favorites_count: count(f.user_id),
            favorited:
              fragment("max(case ? when ? then 1 else 0 end  ) = 1", f.user_id, ^uid) != 0
        }

    case Repo.one(query) do
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

  def update_article(titled_slug, attrs, user) do
    [slug | _] = String.split(titled_slug, "-")

    with article when not is_nil(article) <- Repo.get_by(Article, slug: slug) do
      article
      |> Article.changeset(attrs)
      |> Repo.update()
      |> case do
        {:ok, article} -> get_article_by_slug(article.slug, user)
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
