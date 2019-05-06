defmodule Conduit.Blog do
  import Ecto.Query, warn: false

  alias Conduit.Repo

  alias Conduit.Account.{User, UserFollower}
  alias Conduit.Blog.{Article, Favorite, Comment}

  # article CURD

  def create_article(attrs, user) do
    %Article{author_id: user.id}
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
        join: u in User,
        on: a.author_id == u.id,
        left_join: uf in UserFollower,
        on: uf.follower_id == ^uid and uf.followee_id == u.id,
        where: a.slug == ^slug,
        # 需要group多个字段，在下面计算following需要这样操作，否则SQL会报错
        group_by: [a.id, u.id, uf.follower_id],
        select: %{
          a
          | favorites_count: count(f.user_id),
            favorited:
              fragment("max(case ? when ? then 1 else 0 end  ) = 1", f.user_id, ^uid) != 0,
            # 受限于preload的限制， 在通过join preload的时候，User对象的following不能一步计算完成
            # 需要先映射到Article的这个字段，然后再复制到User对象
            following: not is_nil(uf.follower_id)
        },
        # 最好ecto里面的preload能提供select一样的定制性，但是现在没有
        preload: [author: u]

    case Repo.one(query) do
      nil -> {:error, :not_found}
      article -> {:ok, %{article | author: %{article.author | following: article.following}}}
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
         {:ok, _} <-
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

  # comments

  # add comment 
  def create_comment(titled_slug, attrs, user) do
    [slug | _] = String.split(titled_slug, "-")

    case Repo.get_by(Article, slug: slug) do
      nil ->
        {:error, :not_found}

      article ->
        %Comment{author_id: user.id, article_id: article.id}
        |> Comment.changeset(attrs)
        |> Repo.insert()
    end
  end

  # delete comment 
  def delete_comment(slug, comment_id, user) do
    [slug | _] = String.split(titled_slug, "-")

    case Repo.get_by(Article, slug: slug) do
      nil ->
        {:error, :not_found}

      article ->
        query =
          from c in Comment,
               where(c.article_id == ^article.id and c.author_id == ^user.id)

        case Repo.one(query) do
          nil ->
            {:error, :not_found}

          comment ->
            Repo.delete(comment)
            {:ok, comment}
        end
    end
  end

  # list comment for slug
  def list_comment(slug) do
    [slug | _] = String.split(titled_slug, "-")

    query =
      from c in Comment,
        join: a in Article,
        on: c.article_id == a.id,
        join: u in User,
        on: c.author_id == u.id,
        where: a.slug == ^slug,
        preload: [author: u]

    Repo.all(query)
  end
end
