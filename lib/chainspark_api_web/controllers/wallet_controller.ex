defmodule ChainsparkApiWeb.WalletController do
  use ChainsparkApiWeb, :controller

  alias ChainsparkApi.Wallets

  def index(conn, %{"type" => "all"}) do
    conn
    |> render("index.json-api", data: Wallets.list_wallets)
  end
  def index(conn, %{"type" => type}) do
    conn
    |> render("index.json-api", data: Wallets.list_wallets(type))
  end

  def show(conn, %{"id" => id}) do
    {:ok, wallet} = Wallets.get_by_address_with_details(id)

    conn
    |> render("index.json-api", data: wallet)
  end

  def create(conn, %{"exchanges" => exchanges}) do
    rejected =
      exchanges
        |> Enum.map(fn %{"name" => name, "address" => address, "type" => type} ->
            Wallets.create_wallet(%{
                name: name |> String.trim |> String.capitalize ,
                address: address |> String.trim,
                type: type
              })
          end)
        |> Enum.reject(fn {status, _} -> status == :ok end)

    if length(rejected) > 0 do
      conn
      |> send_resp(202, Jason.encode!(extract_errors(rejected)))
    else
      conn
      |> send_resp(201, "Created")
    end
  end

  defp extract_errors(rejected) do
    rejected
    |> Enum.map(&format_changeset_errors/1)
  end

  defp format_changeset_errors({:error, %{errors: errors, changes: changes}}) do
    errors =
      errors
      |> Enum.map(fn {key, {value, _}} -> {key, value} end)

    %{errors: Map.new(errors)}
    |> Map.put(:name, changes.name)
    |> Map.put(:address, changes.address)
  end
end
