defmodule Conduit.Account do
  import Ecto.Query, warn: false

  alias Conduit.Repo
  alias Conduit.Account.{User}

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
