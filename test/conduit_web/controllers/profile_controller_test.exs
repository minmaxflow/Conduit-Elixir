defmodule ConduitWeb.ProfileControllerTest do
  use ConduitWeb.ConnCase

  alias Conduit.Account

  @user1_attr %{email: "user1@test.com", username: "usr1", password: "user1pass"}
  @user2_attr %{email: "user2@test.com", username: "usr2", password: "user2pass"}

  describe "follow" do
    test "follow with success", %{conn: conn} do
      Account.create_user(@user1_attr)
      Account.create_user(@user2_attr)

      response =
        conn
        |> auth_conn(@user1_attr)
        |> put_req_header("content-type", "application/json")
        |> post(Routes.profile_path(conn, :follow, @user2_attr.username))
        |> json_response(200)

      assert %{
               "profile" => %{
                 "username" => "usr2",
                 "following" => true
               }
             } = response
    end

    test "follow fail", %{conn: conn} do
      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.profile_path(conn, :follow, @user2_attr.username))
        |> json_response(401)

      assert %{"errors" => %{"details" => "unauthorized request"}} == response
    end

    test "unfollow with success", %{conn: conn} do
      {:ok, user1} = Account.create_user(@user1_attr)
      {:ok, user2} = Account.create_user(@user2_attr)

      Account.follow_user(user1, user2.username)

      response =
        conn
        |> auth_conn(@user1_attr)
        |> delete(Routes.profile_path(conn, :unfollow, user2.username))
        |> json_response(200)

      assert %{
               "profile" => %{
                 "username" => "usr2",
                 "following" => false
               }
             } = response
    end

    test "unfollow fail", %{conn: conn} do
      {:ok, user1} = Account.create_user(@user1_attr)
      {:ok, user2} = Account.create_user(@user2_attr)

      Account.follow_user(user1, user2.username)

      response =
        conn
        |> delete(Routes.profile_path(conn, :unfollow, user2.username))
        |> json_response(401)

      assert %{"errors" => %{"details" => "unauthorized request"}} == response
    end
  end

  describe "profile" do
    test "with login", %{conn: conn} do
      {:ok, user1} = Account.create_user(@user1_attr)
      {:ok, user2} = Account.create_user(@user2_attr)

      Account.follow_user(user1, user2.username)

      response =
        conn
        |> auth_conn(@user1_attr)
        |> get(Routes.profile_path(conn, :profile, user2.username))
        |> json_response(200)

      assert %{
               "profile" => %{
                 "following" => true,
                 "username" => "usr2"
               }
             } = response
    end

    test "without login", %{conn: conn} do
      {:ok, user1} = Account.create_user(@user1_attr)
      {:ok, user2} = Account.create_user(@user2_attr)

      Account.follow_user(user1, user2.username)

      response =
        conn
        |> get(Routes.profile_path(conn, :profile, user2.username))
        |> json_response(200)

      assert %{
               "profile" => %{
                 "following" => false,
                 "username" => "usr2"
               }
             } = response
    end
  end

  # copy from user_controller_test.exs
  defp auth_conn(conn, attrs \\ %{}) do
    attrs =
      Map.merge(%{email: "test@test.com", username: "username", password: "password123"}, attrs)

    # 存在重复创建，先忽略。。。
    Account.create_user(attrs)

    response =
      conn
      |> put_req_header("content-type", "application/json")
      |> post(Routes.user_path(conn, :login), Jason.encode!(%{"user" => attrs}))
      |> json_response(200)

    assert %{"user" => %{"token" => token}} = response

    conn
    |> put_req_header("authorization", "Bearer " <> token)
  end
end
