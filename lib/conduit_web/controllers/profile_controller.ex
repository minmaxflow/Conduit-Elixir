defmodule ConduitWeb.ProfileController do
  use ConduitWeb, :controller

  alias Conduit.Account

  def profile(conn, %{"username" => followee_username}) do
    user = Guardian.Plug.current_resource(conn)

    IO.inspect(user, label: "profile")

    with user_profile when not is_nil(user_profile) <- Account.profile(user, followee_username) do
      render(conn, "profile.json", %{profile: user_profile})
    else
      _ -> {:error, :not_found}
    end
  end

  def follow(conn, %{"username" => followee_username}) do
    with user when not is_nil(user) <- Guardian.Plug.current_resource(conn),
         {:ok, followee} <- Account.follow_user(user, followee_username) do
      render(conn, "profile.json", %{profile: followee})
    else
      _ -> {:error, :not_found}
    end
  end

  def unfollow(conn, %{"username" => followee_username}) do
    with user when not is_nil(user) <- Guardian.Plug.current_resource(conn),
         {:ok, followee} <- Account.unfollow_user(user, followee_username) do
      render(conn, "profile.json", %{profile: followee})
    else
      _ -> {:error, :not_found}
    end
  end
end
