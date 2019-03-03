defmodule ChainsparkApiWeb.TransactionController do
  use ChainsparkApiWeb, :controller

  alias ChainsparkApi.Transactions.EthTransaction
  alias ChainsparkApi.Transactions.BtcTransaction
  alias ChainsparkApiWeb.TransactionView
  alias ChainsparkApiWeb.Plug.WatcherAccess
  alias ChainsparkApi.Transactions
  alias ChainsparkApi.Repo

  plug :valid_filters, ~w(exchange time threshold type token wallet) when action in [:index]

  def index(conn, params = %{
      "filter" => %{ "type" => "btc" },
      "page" => %{ "number" => number, "size" => size }
    })
  do
    order = params["order"]

    txns = BtcTransaction
           |> Transactions.filtered_by(conn.assigns.filters)
           |> Transactions.ordered_by(order)
           |> Repo.paginate(page: number, page_size: size)

    JaSerializer.format(TransactionView, txns, conn, [])

    conn
    |> render("index.json-api", data: txns)
  end

  def index(conn, params = %{
      "filter" => %{"type" => _type},
      "page" => %{ "number" => number, "size" => size }
    })
  do
    order = params["order"]

    txns = EthTransaction
           |> Transactions.filtered_by(conn.assigns.filters)
           |> Transactions.ordered_by(order)
           |> Repo.paginate(page: number, page_size: size)

    JaSerializer.format(TransactionView, txns, conn, [])

    conn
    |> render("index.json-api", data: txns)
  end

  def index(%{ assigns: %{ filters: filters }} = conn,
              params = %{"page" => %{ "number" => number, "size" => size }})
  do
    order = params["order"]

    eth_txns = EthTransaction
               |> Transactions.filtered_by(filters)
               |> Transactions.ordered_by(order)
               |> Repo.paginate(page: number, page_size: size)

    btc_txns = BtcTransaction
               |> Transactions.filtered_by(filters)
               |> Transactions.ordered_by(order)
               |> Repo.paginate(page: number, page_size: size)

    total_txns = eth_txns.entries ++ btc_txns.entries

    txns = Map.merge(eth_txns, %{entries: total_txns})

    JaSerializer.format(TransactionView, txns, conn, [])

    conn
    |> render("index.json-api", data: txns)
  end

  def index(conn, _params) do
    eth_txns = EthTransaction
               |> Repo.all

    btc_txns = BtcTransaction
               |> Repo.all

    conn
    |> render("index.json-api", data: eth_txns ++ btc_txns)
  end

  plug WatcherAccess when action in [:create]

  def create(conn, %{ "is_btc_tx" => true } = params) do
    case Transactions.create_btc_transaction(params) do
      {:ok, _transaction } ->
        conn
        |> send_resp(201, "Created")
      {:error, :tx_rejected } ->
        conn
        |> send_resp(202, "Accepted / Not passed threshold")
      {:error, _changeset } ->
        conn
        |> send_resp(500, "Internal server error")
    end
  end

  def create(conn, %{ "is_token_tx" => false} = params) do
    case Transactions.create_eth_transaction(params) do
      {:ok, _transaction} ->
        conn
        |> send_resp(201, "Created")
      {:error, :tx_rejected} ->
        conn
        |> send_resp(202, "Accepted / Not passed threshold")
      {:error, _changeset} ->
        conn
        |> send_resp(500, "Internal server error")
    end
  end

  def create(conn, %{ "is_token_tx" => true} = params) do
    case Transactions.create_erc20_transaction(params) do
      {:ok, _transaction} ->
        conn
        |> send_resp(201, "Created")
      {:error, :tx_rejected} ->
        conn
        |> send_resp(202, "Accepted / Not passed threshold")
      {:error, _error} ->
        conn
        |> send_resp(404, "Not found")
    end
  end

  def highest(conn, _params) do
    with {:ok, txns} <- Transactions.get_highest_txns do
      conn
      |> render("index.json-api", data: txns)
    else
      _ ->
        conn
        |> send_resp(404, "Not Found")
    end
  end

  def valid_filters(conn, params) do
    if Map.has_key?(conn.params, "filter") do
      filters = Enum.filter(conn.params["filter"], fn({k, _v}) ->
        Enum.member?(params, k)
      end)
      conn |> assign(:filters, filters)
    else
      conn
    end
  end
end
