defmodule ConduitWeb.AuthErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  import Phoenix.Controller
  import Plug.Conn

  alias ConduitWeb.ErrorView

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, reason}, opts) do
    conn
    |> put_status(401)
    |> put_view(ErrorView)
    |> render("401.json")
  end
end
