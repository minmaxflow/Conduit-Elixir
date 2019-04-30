defmodule ConduitWeb.Router do
  use ConduitWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :opt_auth do
    plug ConduitWeb.AuthOptPipeLine
  end

  pipeline :auth do
    plug ConduitWeb.AuthPipeLine
  end

  scope "/api", ConduitWeb do
    pipe_through [:api, :opt_auth]

    # user register/login
    post "/users", UserController, :create
    post "/user/api/users/login", UserController, :login

    # profile
    get "/profiles/:username", ProfileController, :profile
  end

  scope "/api", ConduitWeb do
    pipe_through [:api, :auth]

    # user
    get "/user", UserController, :current

    post "/profile/:username/follow", ProfileController, :follow
    delete "/profile/:username/follow", ProfileController, :unfollow
  end
end
