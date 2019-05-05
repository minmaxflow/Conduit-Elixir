defmodule Conduit.Repo.Migrations.CreateUserFollowers do
  use Ecto.Migration

  def change do
    create table(:user_followers, primary_key: false) do
      add :follower_id, references(:users, on_delete: :delete_all), primary_key: true
      add :followee_id, references(:users, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    # 假设数据库会基于主键创建(follower_id, followee_id)的唯一索引
    create index(:user_followers, [:followee_id])
  end
end
