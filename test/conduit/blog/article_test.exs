defmodule Conduit.Blog.ArticleTest do
  use Conduit.DataCase

  alias Ecto.Changeset

  alias Conduit.Account
  alias Conduit.Account.User

  alias Conduit.Blog
  alias Conduit.Blog.Article

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
               Blog.update_article(titled_slug, %{title: "new title"})

      # error not found 
      assert {:error, :not_found} = Blog.update_article("wrong slug title", %{})

      # error changeset
      assert {:error, %Changeset{}} = Blog.update_article(titled_slug, %{title: ""})
    end
  end

  defp prepare_data() do
    {:ok, user} = Account.create_user(@user_attr)
    {:ok, article} = Blog.create_article(@article_attr, user)

    {article, article.slug <> "-" <> Article.slugify_title(article.title)}
  end
end
