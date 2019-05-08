defmodule ConduitWeb.CommentControllerTest do
  use ConduitWeb.ConnCase

  alias Conduit.Account
  alias Conduit.Blog

  @user_attr %{email: "test@test.com", username: "username", password: "password123"}
  @article_attr %{title: "title", description: "description", body: "article body"}
  @comment_attr %{body: "comment body"}

  setup %{conn: conn} do
    {:ok, user} = Account.create_user(@user_attr)

    response =
      conn
      |> put_req_header("content-type", "application/json")
      |> post(Routes.user_path(conn, :login), Jason.encode!(%{"user" => @user_attr}))
      |> json_response(200)

    %{"user" => %{"token" => token}} = response

    {:ok,
     user: user,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("content-type", "application/json")
       |> put_req_header("authorization", "Token " <> token)}
  end

  test "comment rest api", %{conn: conn, user: _user} do
    {:ok, user2} =
      Account.create_user(%{
        email: "test2@test.com",
        username: "username2",
        password: "password123"
      })

    {:ok, %{slug: slug}} = Blog.create_article(@article_attr, user2)

    # create
    conn = post(conn, Routes.comment_path(conn, :create, slug), %{"comment" => @comment_attr})

    assert %{
             "comment" => %{
               "body" => "comment body",
               "author" => %{
                 "username" => "username",
                 "following" => false
               }
             }
           } = json_response(conn, 200)

    # list 
    conn = get(conn, Routes.comment_path(conn, :index, slug))

    assert %{
             "comments" => [
               %{
                 "body" => "comment body",
                 "id" => id,
                 "author" => %{
                   "username" => "username",
                   "following" => false
                 }
               }
               | _
             ]
           } = json_response(conn, 200)

    # delete 
    conn = delete(conn, Routes.comment_path(conn, :delete, slug, id))

    assert %{
             "comment" => %{
               "author" => nil,
               "id" => ^id
             }
           } = json_response(conn, 200)
  end
end
