defmodule ConduitWeb.Router do
  use ConduitWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ConduitWeb do
    pipe_through :api

    # user
    post "/users", UserController, :create

    # profile
    get "/profiles/:username", ProfileController, :profile
    post "/profile/:username/follow", ProfileController, :follow
    delete "/profile/:username/follow", ProfileController, :unfollow
  end
end
