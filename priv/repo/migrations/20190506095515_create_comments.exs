defmodule Conduit.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :string

      add :author_id, references(:users)
      add :article_id, references(:articles)

      timestamps()
    end

    create index(:comments, [:article_id])
  end
end
