defmodule Conduit.Blog.Favorite do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Account.User
  alias Conduit.Blog.Article

  @primary_key false
  schema "favorites" do
    belongs_to :user, User, foreign_key: :user_id, primary_key: true
    belongs_to :article, Article, foreign_key: :article_id, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(favorite, attrs) do
    favorite
    |> cast(attrs, [:user_id, :article_id])
    |> validate_required([:user_id, :article_id])
  end
end
