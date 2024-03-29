defmodule Conduit.Account do
  import Ecto.Query, warn: false

  alias Conduit.Repo
  alias Conduit.Account.{User, UserFollower}
  alias Comeonin.Bcrypt

  def get_user(id) do
    Repo.get(User, id)
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    query = from u in User, where: u.email == ^email

    case Repo.one(query) do
      nil ->
        Bcrypt.dummy_checkpw()
        {:error, :unauthorized}

      user ->
        if Bcrypt.checkpw(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  # 使用left_join来一步判定
  def profile(current_user, followee_username) do
    uid =
      case current_user do
        nil -> -1
        current_user -> current_user.id
      end

    query =
      from u in User,
        left_join: uf in UserFollower,
        on: u.id == uf.followee_id and uf.follower_id == ^uid,
        where: u.username == ^followee_username,
        select: %{u | following: not is_nil(uf.follower_id)}

    Repo.one(query)
  end

  def follow_user(follower, followee_username) do
    query = from u in User, where: u.username == ^followee_username

    case Repo.one(query) do
      nil ->
        {:error, :not_found}

      followee ->
        %UserFollower{}
        |> UserFollower.changeset(%{follower_id: follower.id, followee_id: followee.id})
        |> Repo.insert()

        followee = %{followee | password_hash: nil, following: true}
        {:ok, followee}
    end
  end

  def unfollow_user(follower, followee_username) do
    query = from u in User, where: u.username == ^followee_username

    with followee when not is_nil(followee) <- Repo.one(query),
         user_follow when not is_nil(user_follow) <-
           Repo.get_by(UserFollower, follower_id: follower.id, followee_id: followee.id) do
      Repo.delete(user_follow)

      followee = %{followee | password_hash: nil, following: false}
      {:ok, followee}
    else
      _ -> {:error, :not_found}
    end
  end
end
