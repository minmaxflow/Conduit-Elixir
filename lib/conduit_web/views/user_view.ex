defmodule ConduitWeb.UserView do
  use ConduitWeb, :view

  def render("user.json", %{user: user}) do
    %{
      user: %{
        email: user.email,
        token: user.token,
        username: user.username,
        bio: user.bio,
        image: user.image
      }
    }
  end
end
