defmodule ConduitWeb.ProfileController do
  use ConduitWeb, :controller

  alias Conduit.Account

  # TODO，没加上这个也起作用了，没明白
  action_fallback ConduitWeb.FallbackController

  def profile(conn, %{"username" => followee_username}) do
    user = Guardian.Plug.current_resource(conn)

    with user_profile when not is_nil(user_profile) <- Account.profile(user, followee_username) do
      render(conn, "show.json", %{profile: user_profile})
    else
      _ -> {:error, :not_found}
    end
  end

  def follow(conn, %{"username" => followee_username}) do
    with user when not is_nil(user) <- Guardian.Plug.current_resource(conn),
         {:ok, followee} <- Account.follow_user(user, followee_username) do
      render(conn, "show.json", %{profile: followee})
    else
      _ -> {:error, :not_found}
    end
  end

  def unfollow(conn, %{"username" => followee_username}) do
    with user when not is_nil(user) <- Guardian.Plug.current_resource(conn),
         {:ok, followee} <- Account.unfollow_user(user, followee_username) do
      render(conn, "show.json", %{profile: followee})
    else
      _ -> {:error, :not_found}
    end
  end
end
