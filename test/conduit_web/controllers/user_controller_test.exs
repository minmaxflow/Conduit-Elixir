defmodule ConduitWeb.UserControllerTest do
  use ConduitWeb.ConnCase

  @valid_attr %{email: "test@test.com", username: "username", password: "password123"}

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

      # 需要verify token
    end

    test "create to register with invalid data" do
    end
  end
end
