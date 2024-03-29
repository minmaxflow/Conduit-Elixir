# 部分代码参考 https://github.com/hashrocket/tilex/blob/f43c70e06258c011fe90b9779b8a295d97caedf4/web/models/post.ex

defmodule Conduit.Blog.Article do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Account.User
  alias Conduit.Blog.{Comment, Tag}

  schema "articles" do
    field :body, :string
    field :description, :string
    field :slug, :string
    field :title, :string

    belongs_to :author, User, foreign_key: :author_id
    has_many :comments, Comment, foreign_key: :article_id
    many_to_many :tags, Tag, join_through: "articles_tags", on_replace: :delete

    field :favorited, :boolean, virtual: true, default: false
    field :favorites_count, :integer, virtual: true, default: 0

    field :following, :boolean, virtual: true, default: false

    timestamps()
  end

  def slugify_title(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^A-Za-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :description, :body, :author_id])
    |> validate_required([:title, :body, :author_id])
    |> validate_length(:title, max: 50, min: 3)
    |> validate_length(:description, max: 1000)
    |> add_slug
  end

  def generate_slug do
    :base64.encode(:crypto.strong_rand_bytes(16))
    |> String.replace(~r/[^A-Za-z0-9]/, "")
    |> String.slice(0, 10)
    |> String.downcase()
  end

  defp add_slug(changeset) do
    unless get_field(changeset, :slug) do
      put_change(changeset, :slug, generate_slug())
    else
      changeset
    end
  end
end
