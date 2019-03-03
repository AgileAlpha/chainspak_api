defmodule ChainsparkApiWeb.Plug.AuthAccessPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :chainspark_api,
    module: ChainsparkApi.Guardian,
    error_handler: ChainsparkApi.Plug.AuthErrorHandler

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end

