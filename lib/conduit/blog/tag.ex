defmodule Conduit.Blog.Tag do
  use Conduit.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 2)
    |> unique_constraint(:name)
  end
end
