defmodule ChainsparkApiWeb.SessionController do
  use ChainsparkApiWeb, :controller

  alias ChainsparkApi.Accounts
  
  def create(conn, %{ "session" => %{ "email" => email, "password" => pass }}) do
    case Accounts.get_user_by_email_and_password(email, pass) do
      {:ok, user } ->
        {:ok, jwt, _claims } = ChainsparkApi.Guardian.encode_and_sign(user)

        conn
        |> put_resp_header("authorization", "Bearer #{jwt}")
        |> render("create.json", jwt: jwt)
      {:error, _reason } ->
        conn
        |> send_resp(401, "Unauthorized")
    end
  end
end
