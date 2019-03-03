defmodule ChainsparkApiWeb.Plug.AppAccess do
  import Plug.Conn

  @access_key Application.get_env(:chainspark_api, :app_access_key)

  def init(opts), do: opts

  def call(conn, _opts) do
    secret = conn |> get_req_header("chainspark-secret")

    conn
    |> check_secret(secret)
  end

  defp check_secret(conn, []) do
    conn
      |> send_resp(401, "Unauthorized")
      |> halt()
  end
  defp check_secret(conn, [secret]) when secret == @access_key do
    conn
  end
  defp check_secret(conn, [_secret]) do
    conn
      |> send_resp(401, "Unauthorized")
      |> halt()
  end
end
