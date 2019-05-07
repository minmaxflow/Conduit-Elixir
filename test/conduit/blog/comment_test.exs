defmodule Conduit.Blog.CommentTest do
  use Conduit.DataCase

  alias Conduit.Account
  alias Conduit.Account.User

  alias Conduit.Blog
  alias Conduit.Blog.{Article, Comment}

  @user_attr %{email: "test@test.com", username: "username", password: "password123"}
  @article_attr %{title: "title", description: "description", body: "article body"}
  @comment_attr %{body: "comment body"}

  test "comment create/delete/list" do
    {:ok, user} = Account.create_user(@user_attr)

    {:ok, user2} =
      Account.create_user(%{
        email: "test2@test.com",
        username: "username2",
        password: "password123"
      })

    {:ok, %Article{slug: slug}} = Blog.create_article(@article_attr, user)

    assert {:ok,
            %Comment{
              id: comment_id,
              body: "comment body",
              author: %User{username: "username2", following: false}
            }} = Blog.create_comment(slug, @comment_attr, user2)

    assert [%{author: %{following: false}} | _] = Blog.list_comment(slug, nil)
    Account.follow_user(user, user2.username)
    assert [%{author: %{following: true}} | _] = Blog.list_comment(slug, user)

    assert {:error, :not_found} = Blog.delete_comment(slug, comment_id, user)
    assert {:ok, %Comment{id: ^comment_id}} = Blog.delete_comment(slug, comment_id, user2)
  end
end
