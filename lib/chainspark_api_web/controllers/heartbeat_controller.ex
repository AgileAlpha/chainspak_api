defmodule ChainsparkApiWeb.HeartbeatController do
  use ChainsparkApiWeb, :controller

  def index(conn, _params) do
    conn
    |> send_resp(200, "OK")
  end
end
