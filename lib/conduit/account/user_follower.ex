defmodule Conduit.Account.UserFollower do
  use Conduit.Schema
  import Ecto.Changeset

  alias Conduit.Account.User

  @primary_key false
  schema "user_followers" do
    belongs_to :follower, User, foreign_key: :follower_id, primary_key: true
    belongs_to :followee, User, foreign_key: :followee_id, primary_key: true

    timestamps()
  end

  @doc false
  def changeset(user_follower, attrs) do
    user_follower
    |> cast(attrs, [:follower_id, :followee_id])
    |> validate_required([:follower_id, :followee_id])
  end
end
