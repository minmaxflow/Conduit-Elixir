defmodule ConduitWeb.UserController do
  use ConduitWeb, :controller

  alias Conduit.Account
  alias ConduitWeb.Guardian

  action_fallback ConduitWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Account.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      user = %{user | token: token}
      render(conn, "user.json", user: user)
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    with {:ok, user} <- Account.authenticate_user(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      user = %{user | token: token}
      render(conn, "user.json", user: user)
    else
      _ -> {:error, :unauthorized}
    end
  end

  defp current(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    conn |> render(conn, "user.json", user: user)
  end
end
