defmodule Conduit.Account.User do
  use Conduit.Schema
  import Ecto.Changeset

  schema "users" do
    field :bio, :string
    field :email, :string
    field :image, :string
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password_hash, :username, :bio, :image])
    |> validate_required([:email, :password_hash, :username])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end
end
