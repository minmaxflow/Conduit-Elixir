defmodule Conduit.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
    end

    create unique_index(:tags, [:name])

    create table(:articles_tags, primary_key: false) do
      add :article_id, references(:articles), primary_key: true
      add :tag_id, references(:tags), primary_key: true
    end

    create index(:articles_tags, [:tag_id])
  end
end
