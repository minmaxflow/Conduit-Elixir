defmodule Conduit.Account.User do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Blog.Article

  schema "users" do
    field :bio, :string
    field :email, :string
    field :image, :string
    field :password_hash, :string
    field :username, :string

    has_many :articles, Article, foreign_key: :author_id

    field :password, :string, virtual: true
    field :token, :string, virtual: true
    field :following, :boolean, virtual: true, default: false

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username, :bio, :image])
    |> validate_required([:email, :password, :username])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:username, min: 3, max: 100)
    |> encrpyt_password()
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
