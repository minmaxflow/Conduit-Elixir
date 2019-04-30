defmodule Conduit.Repo.Migrations.CreateUserFollowers do
  use Ecto.Migration

  def change do
    create table(:user_followers, primary_key: false) do
      add :follower_id, references(:users, on_delete: :delete_all), primary_key: true
      add :followee_id, references(:users, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create index(:user_followers, [:followee_id])
  end
end
