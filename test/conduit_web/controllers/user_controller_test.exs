defmodule ConduitWeb.UserControllerTest do
  use ConduitWeb.ConnCase

  alias Conduit.Account

  @valid_attr %{email: "test@test.com", username: "username", password: "password123"}
  @inalid_attr %{email: "test@test.com", username: "ab", password: "password123"}

  describe "create " do
    test "create to register with valid data", %{conn: conn} do
      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.user_path(conn, :create), Jason.encode!(%{"user" => @valid_attr}))
        |> json_response(200)

      assert %{
               "user" => %{
                 "email" => "test@test.com",
                 "token" => token,
                 "username" => "username",
                 "bio" => nil,
                 "image" => nil
               }
             } = response

      assert token
    end

    test "create to register with invalid data", %{conn: conn} do
      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.user_path(conn, :create), Jason.encode!(%{"user" => @inalid_attr}))
        |> json_response(422)

      assert %{
               "errors" => %{
                 "username" => ["should be at least 3 character(s)"]
               }
             } == response
    end
  end

  describe "login" do
    test "login with valid email/password", %{conn: conn} do
      Account.create_user(@valid_attr)

      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.user_path(conn, :login), Jason.encode!(%{"user" => @valid_attr}))
        |> json_response(200)

      assert %{
               "user" => %{
                 "email" => "test@test.com",
                 "token" => token,
                 "username" => "username"
               }
             } = response

      assert token
    end

    test "login with invalid email/password", %{conn: conn} do
      Account.create_user(@valid_attr)

      response =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(
          Routes.user_path(conn, :login),
          Jason.encode!(%{"user" => %{email: "test@test.com", password: "error password"}})
        )
        |> json_response(401)

      assert response == %{"errors" => %{"details" => "unauthorized request"}}
    end
  end

  describe "auth pipline" do
    test "direct access with auth return error", %{conn: conn} do
      response =
        conn
        |> get("/api/user")
        |> json_response(401)

      assert response == %{"errors" => %{"details" => "unauthorized request"}}
    end
  end

  test "login then access ", %{conn: conn} do
  end
end
