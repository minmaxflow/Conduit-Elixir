defmodule ConduitWeb.AuthPipeLine do
  use Guardian.Plug.Pipeline,
    otp_app: :conduit,
    module: ConduitWeb.Guardian,
    error_handler: ConduitWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
