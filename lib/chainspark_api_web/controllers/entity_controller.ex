defmodule ChainsparkApiWeb.EntityController do
  use ChainsparkApiWeb, :controller

  alias ChainsparkApi.Entities

  def index(conn, _params) do
    entities = Entities.list_all

    conn
    |> render("index.json", data: entities)
  end

  def show(conn, %{ "id" => name }) do
    case Entities.get_by_name(name) do
      {:ok, entity } ->
        conn
        |> render("show.json", entity: entity)
      {:error, _} ->
        conn
        |> send_resp(404, "Not found")
    end
  end
end
