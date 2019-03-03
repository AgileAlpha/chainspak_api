defmodule ChainsparkApiWeb.Plug.WatcherAccess do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    [secret] = conn |> get_req_header("chainspark-secret")
    case secret == "123" do
      true -> 
        conn
      _ ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()  
    end
  end
end
