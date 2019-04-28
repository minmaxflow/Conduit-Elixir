defmodule Conduit.Account.User do
  use Conduit.Schema
  import Ecto.Changeset

  schema "users" do
    field :bio, :string
    field :email, :string
    field :image, :string
    field :password_hash, :string
    field :username, :string

    field :password, :string, virtual: true
    field :token, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username, :bio, :image])
    |> encrpyt_password()
    |> validate_required([:email, :password_hash, :username])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:username, min: 3, max: 100)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  defp encrpyt_password(changeset) do
    with password when not is_nil(password) <- get_change(changeset, :password) do
      put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
    else
      _ -> changeset
    end
  end
end
