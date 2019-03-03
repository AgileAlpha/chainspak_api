defmodule ChainsparkApi.Plug.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Poison.encode!(%{ message: to_string(type)})
    conn
    |> send_resp(401, body)
    |> halt()
  end
end

