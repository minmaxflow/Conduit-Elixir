defmodule ConduitWeb.UserController do
  use ConduitWeb, :controller

  alias Conduit.Account

  # 这个可以放到 ConduitWeb里面，暂时不动
  action_fallback ConduitWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    case Account.create_user(user_params) do
      {:ok, user} -> render(conn, "user.json", user: user)
      {:error, changeset} -> changeset
    end
  end
end
