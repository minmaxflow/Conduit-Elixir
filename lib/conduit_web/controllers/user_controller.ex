defmodule ConduitWeb.UserController do
  use ConduitWeb, :controller

  alias Conduit.Account

  action_fallback ConduitWeb.FallbackController

  def register(conn, params) do
    case Account.create_user(params) do
      {:ok, user} -> render(conn, "user.json", user: user)
      {:error, changeset} -> changeset
    end
  end
end
