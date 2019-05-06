defmodule Conduit.Blog.ArticleTest do
  use Conduit.DataCase

  alias Ecto.Changeset

  alias Conduit.Account
  alias Conduit.Account.User

  alias Conduit.Blog
  alias Conduit.Blog.{Article}

  @user_attr %{email: "test@test.com", username: "username", password: "password123"}
  @article_attr %{title: "title", description: "description", body: "article body"}

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
                }
              }} = Blog.create_article(@article_attr, user)

      assert String.length(slug) == 10

      attrs = %{@article_attr | title: nil}
      assert {:error, %Changeset{}} = Blog.create_article(attrs, user)
    end

    test "get by slug" do
      {_, titled_slug} = prepare_data()

      assert {:ok, %Article{author: %User{}}} = Blog.get_article_by_slug(titled_slug, nil)

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
      assert {:ok, %Article{title: "new title", author: %User{}}} =
               Blog.update_article(titled_slug, %{title: "new title"}, nil)

      # error not found 
      assert {:error, :not_found} = Blog.update_article("wrong slug title", %{}, nil)

      # error changeset
      assert {:error, %Changeset{}} = Blog.update_article(titled_slug, %{title: ""}, nil)
    end
  end

  defp prepare_data() do
    {:ok, user} = Account.create_user(@user_attr)
    {:ok, article} = Blog.create_article(@article_attr, user)

    {article, article.slug <> "-" <> Article.slugify_title(article.title)}
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
end
