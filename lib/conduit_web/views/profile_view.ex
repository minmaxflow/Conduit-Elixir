defmodule ConduitWeb.ProfileView do
  use ConduitWeb, :view

  def render("profile.json", %{profile: profile}) do
    %{
      profile: %{
        username: profile.username,
        bio: profile.bio,
        image: profile.image,
        following: profile.following
      }
    }
  end
end
