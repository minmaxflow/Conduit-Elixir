defmodule Conduit.Account do
  import Ecto.Query, warn: false

  alias Conduit.Repo
  alias Conduit.Account.{User}
  alias Comeonin.Bcrypt

  def get_user(id) do
    Repo.get(User, id)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    query = from u in User, where: u.email == ^email

    case Repo.one(query) do
      nil ->
        Bcrypt.dummy_checkpw()
        {:error, :unauthorized}

      user ->
        if Bcrypt.checkpw(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end
end
