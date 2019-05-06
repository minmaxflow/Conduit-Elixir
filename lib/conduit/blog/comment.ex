defmodule Conduit.Blog.Comment do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Account.User
  alias Conduit.Blog.Article

  schema "comments" do
    field :body, :string

    belongs_to :author, User, foreign_key: :author_id
    belongs_to :article, Article, foreign_key: :article_id

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :author_id, :article_id])
    |> validate_required([:body, :author_id, :article_id])
  end
end
