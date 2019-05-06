defmodule ConduitWeb.ArticleControllerTest do
  use ConduitWeb.ConnCase

  alias Conduit.Blog

  alias Conduit.Account
  alias Conduit.Account.User
  alias Conduit.Repo

  @user_attr %{email: "user1@test.com", username: "usr1", password: "user1pass"}

  @create_attrs %{title: "title", description: "description", body: "body"}
  @update_attrs %{tilte: "new title"}
  @invalid_attrs %{title: "t"}

  def fixture(:article) do
    user = Repo.get_by(User, username: "usr1")

    {:ok, article} = Blog.create_article(@create_attrs, user)
    article
  end

  setup %{conn: conn} do
    Account.create_user(@user_attr)

    response =
      conn
      |> put_req_header("content-type", "application/json")
      |> post(Routes.user_path(conn, :login), Jason.encode!(%{"user" => @user_attr}))
      |> json_response(200)

    %{"user" => %{"token" => token}} = response

    {:ok,
     conn:
       conn
       |> put_req_header("accept", "application/json")
       |> put_req_header("content-type", "application/json")
       |> put_req_header("authorization", "Bearer " <> token)}
  end

  describe "create article" do
    test "renders article when data is valid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @create_attrs)

      assert %{
               "article" => %{
                 "title" => "title",
                 "slug" => slug,
                 "author" => %{
                   "username" => "usr1"
                 }
               }
             } = json_response(conn, 201)

      conn = get(conn, Routes.article_path(conn, :show, slug))

      assert %{
               "id" => id
             } = json_response(conn, 200)["article"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update article" do
    setup [:create_article]

    test "renders article when data is valid", %{conn: conn, article: article} do
      conn = put(conn, Routes.article_path(conn, :update, article.slug), article: @update_attrs)
      assert %{"slug" => slug} = json_response(conn, 200)["article"]

      conn = get(conn, Routes.article_path(conn, :show, slug))

      assert %{
               "slug" => ^slug
             } = json_response(conn, 200)["article"]
    end

    test "renders errors when data is invalid", %{conn: conn, article: article} do
      conn = put(conn, Routes.article_path(conn, :update, article.slug), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete article" do
    setup [:create_article]

    test "deletes chosen article", %{conn: conn, article: article} do
      conn = delete(conn, Routes.article_path(conn, :delete, article.slug))
      assert response(conn, 200)

      conn = get(conn, Routes.article_path(conn, :show, article.slug))
      assert response(conn, 404)
    end
  end

  describe "article favorite" do
    setup [:create_article]

    test "fav/unfav", %{conn: conn, article: article} do
      conn = post(conn, Routes.article_path(conn, :favorite, article.slug))

      assert %{} = json_response(conn, 200)

      conn = delete(conn, Routes.article_path(conn, :unfavorite, article.slug))

      assert %{} = json_response(conn, 200)
    end
  end

  defp create_article(_) do
    article = fixture(:article)
    {:ok, article: article}
  end
end
