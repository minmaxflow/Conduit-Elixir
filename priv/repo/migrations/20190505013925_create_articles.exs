defmodule Conduit.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :slug, :string
      add :title, :string
      add :description, :string
      add :body, :string

      add :author_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
