defmodule Conduit.Blog.ArticleTest do
  use Conduit.DataCase

  alias Ecto.Changeset

  alias Conduit.Account
  alias Conduit.Account.User

  alias Conduit.Blog
  alias Conduit.Blog.{Article}

  @user_attr %{email: "test@test.com", username: "username", password: "password123"}
  @article_attr %{
    title: "title",
    description: "description",
    body: "article body",
    tagList: ["tag1", "tag2"]
  }

  test "slug the title" do
    title = "Hacking Your Shower!!!"
    result = "hacking-your-shower"
    assert Article.slugify_title(title) == result
  end

  describe "article crud" do
    test "create" do
      {:ok, user} = Account.create_user(@user_attr)

      assert {:ok,
              %{
                title: "title",
                description: "description",
                body: "article body",
                slug: slug,
                author: %{
                  username: "username"
                },
                tags: [%{name: "tag1"}, %{name: "tag2"}]
              }} = Blog.create_article(@article_attr, user)

      assert String.length(slug) == 10

      attrs = %{@article_attr | title: nil}
      assert {:error, %Changeset{}} = Blog.create_article(attrs, user)
    end

    test "get by slug" do
      {_, titled_slug} = prepare_data()

      assert {:ok, %Article{tags: [%{name: "tag1"}, %{name: "tag2"}], author: %User{}}} =
               Blog.get_article_by_slug(titled_slug, nil)

      assert {:error, :not_found} = Blog.get_article_by_slug("wrong slug title", nil)
    end

    test "delete by slug" do
      {_, titled_slug} = prepare_data()
      assert {:ok, %Article{}} = Blog.delete_article_by_slug(titled_slug)
      assert {:error, :not_found} = Blog.delete_article_by_slug("wrong slug title")
    end

    test "update by slug" do
      {_, titled_slug} = prepare_data()

      # sucesses
      assert {:ok,
              %Article{
                title: "new title",
                tags: [%{name: "tag2"}, %{name: "tag3"}],
                author: %User{}
              }} =
               Blog.update_article(
                 titled_slug,
                 %{title: "new title", tagList: ["tag2", "tag3"]},
                 nil
               )

      # error not found 
      assert {:error, :not_found} = Blog.update_article("wrong slug title", %{}, nil)

      # error changeset
      assert {:error, %Changeset{}} = Blog.update_article(titled_slug, %{title: ""}, nil)
    end
  end

  test "article list/feed" do
    # prepare data
    {:ok, user} =
      Account.create_user(%{email: "test@test.com", username: "username", password: "password123"})

    {:ok, user2} =
      Account.create_user(%{
        email: "test2@test.com",
        username: "username2",
        password: "password123"
      })

    {:ok, article} =
      Blog.create_article(
        %{
          title: "title",
          description: "description",
          body: "article body",
          tagList: ["tag1", "tag2"]
        },
        user
      )

    {:ok, article2} =
      Blog.create_article(
        %{
          title: "title2",
          description: "description2",
          body: "article body2",
          tagList: ["tag2", "tag3"]
        },
        user2
      )

    # test Tag 
    assert [
             %{
               body: "article body2",
               author: %{
                 username: "username2",
                 following: false
               },
               tags: [%{name: "tag2"}, %{name: "tag3"}]
             }
           ] = Blog.list_articles(%{"tag" => "tag3"}, nil)

    assert [
             %{
               body: "article body2",
               author: %{
                 username: "username2",
                 following: false
               },
               tags: [%{name: "tag2"}, %{name: "tag3"}]
             },
             %{
               body: "article body",
               author: %{
                 username: "username",
                 following: false
               },
               tags: [%{name: "tag1"}, %{name: "tag2"}]
             }
           ] = Blog.list_articles(%{"tag" => "tag2"}, nil)

    # author
    assert [
             %{
               body: "article body2",
               author: %{
                 username: "username2",
                 following: false
               },
               tags: [%{name: "tag2"}, %{name: "tag3"}]
             }
           ] = Blog.list_articles(%{"author" => "username2"}, nil)

    # favorited

    assert [] = Blog.list_articles(%{"favorited" => "username2"}, nil)

    Blog.favorite(article.slug, user2)

    assert [
             %{
               body: "article body",
               favorited: false,
               favorites_count: 1,
               author: %{
                 username: "username",
                 following: false
               },
               tags: [%{name: "tag1"}, %{name: "tag2"}]
             }
           ] = Blog.list_articles(%{"favorited" => "username2"}, nil)

    assert [
             %{
               body: "article body",
               favorited: true,
               favorites_count: 1,
               author: %{
                 username: "username",
                 following: false
               },
               tags: [%{name: "tag1"}, %{name: "tag2"}]
             }
           ] = Blog.list_articles(%{"favorited" => "username2"}, user2)

    # feed
    assert [] = Blog.list_articles_feed(nil, user)

    Account.follow_user(user, user2.username)

    assert [
             %{
               body: "article body2",
               author: %{
                 username: "username2",
                 following: true
               },
               tags: [%{name: "tag2"}, %{name: "tag3"}]
             }
           ] = Blog.list_articles_feed(nil, user)
  end

  describe "article favorited" do
    test "fav/unfav" do
      {:ok, user} = Account.create_user(@user_attr)

      {:ok, user2} =
        Account.create_user(%{
          email: "test2@test.com",
          username: "username2",
          password: "password123"
        })

      {:ok, article} = Blog.create_article(@article_attr, user)

      assert {:ok,
              %{
                favorited: false,
                favorites_count: 0
              }} = Blog.get_article_by_slug(article.slug, user)

      assert {:ok,
              %{
                favorited: true,
                favorites_count: 1
              }} = Blog.favorite(article.slug, user)

      assert {:ok,
              %{
                favorited: false,
                favorites_count: 1
              }} = Blog.get_article_by_slug(article.slug, nil)

      assert {:ok,
              %{
                favorited: false,
                favorites_count: 1
              }} = Blog.get_article_by_slug(article.slug, user2)

      assert {:ok,
              %{
                favorited: true,
                favorites_count: 2
              }} = Blog.favorite(article.slug, user2)

      assert {:ok,
              %{
                favorited: false,
                favorites_count: 1
              }} = Blog.un_favorite(article.slug, user2)

      assert {:ok,
              %{
                favorited: false,
                favorites_count: 0
              }} = Blog.un_favorite(article.slug, user)
    end
  end

  describe "article -> user" do
    test "follow/unfollowing" do
      {:ok, user} = Account.create_user(@user_attr)

      {:ok, user2} =
        Account.create_user(%{
          email: "test2@test.com",
          username: "username2",
          password: "password123"
        })

      {:ok, article} = Blog.create_article(@article_attr, user)

      assert {:ok, %{author: %{following: false}}} = Blog.get_article_by_slug(article.slug, user2)

      Account.follow_user(user2, user.username)
      assert {:ok, %{author: %{following: true}}} = Blog.get_article_by_slug(article.slug, user2)
    end
  end

  defp prepare_data() do
    {:ok, user} = Account.create_user(@user_attr)
    {:ok, article} = Blog.create_article(@article_attr, user)

    {article, article.slug <> "-" <> Article.slugify_title(article.title)}
  end
end
