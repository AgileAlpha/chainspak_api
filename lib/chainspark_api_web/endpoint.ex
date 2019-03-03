defmodule ChainsparkApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chainspark_api

  socket "/api/socket", ChainsparkApiWeb.Socket,
    websocket: true,
    longpoll: true

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :chainspark_api, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger
  plug CORSPlug,
    origin: "*",
    headers: [
      "Authorization",
      "Chainspark-secret",
      "Content-Type",
      "Accept",
      "Origin",
      "User-Agent",
      "Cache-Control",
      "Keep-Alive",
      "X-CSRF-Token"
    ]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_chainspark_api_key",
    signing_salt: "mNK01eQX"

  plug ChainsparkApiWeb.Router
end
