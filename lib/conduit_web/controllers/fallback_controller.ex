defmodule ConduitWeb.FallbackController do
  import Phoenix.Controller
  import Plug.Conn

  alias ConduitWeb.ErrorView
  alias Ecto.Changeset

  def init(opts), do: opts

  def call(conn, {:error, %Changeset{} = changset}) do
    conn
    |> put_status(422)
    |> put_view(ErrorView)
    |> render("422.json", errors: errors(changset))
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(401)
    |> put_view(ErrorView)
    |> render("401.json")
  end

  # default
  def call(conn, _opts) do
    conn
    |> put_status(404)
    |> put_view(ErrorView)
    |> render("404.json")
  end

  defp errors(changset) do
    Changeset.traverse_errors(changset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
