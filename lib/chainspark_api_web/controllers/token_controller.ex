defmodule ChainsparkApiWeb.TokenController do
  use ChainsparkApiWeb, :controller

  alias ChainsparkApi.Tokens

  def index(conn, _) do
    tokens = Tokens.list_tokens

    conn
    |> put_resp_header("content-type", "application/vnd.api+json; charset=utf-8")
    |> render("index.json", data: tokens)
  end

  def show(conn, %{ "id" => symbol }) do
    case Tokens.get_by_symbol(symbol) do
      {:ok, token } ->
        conn
        |> put_resp_header("content-type", "application/vnd.api+json; charset=utf-8")
        |> render("show.json", data: token)
      {:error, _} ->
        conn
        |> send_resp(404, "Not found")
    end
  end
end
