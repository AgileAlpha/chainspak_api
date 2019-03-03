defmodule ChainsparkApi.Transactions do
  import Ecto.Query, warn: false

  import ChainsparkApi.Transactions.Util

  alias ChainsparkApi.Repo
  alias ChainsparkApi.Transactions.EthTransaction
  alias ChainsparkApi.Transactions.BtcTransaction
  alias ChainsparkApi.Tokens

  alias ChainsparkApiWeb.TransactionView
  alias ChainsparkApiWeb.TransactionChannel

  def list_eth_transactions(filter \\ %{})
  def list_eth_transactions(_) do
    Repo.all(EthTransaction)
  end

  def list_btc_transactions do
    Repo.all(BtcTransaction)
  end

  def get(id), do: Repo.get(Transaction, id)

  def ordered_by(query, nil), do: query |> order_by(desc: :timestamp)
  def ordered_by(query, params) do
    {key, order} = params
                  |> Map.to_list
                  |> Enum.at(0)
    case key do
      "value" ->
        q = query_order(order, :cents_value)
        order_by(query, ^q)
      "amount" ->
        q = query_order(order, :token_amount)
        order_by(query, ^q)
      "time" ->
        q = query_order(order, :timestamp)
        order_by(query, ^q)
      _ -> query |> order_by(desc: :timestamp)
    end
  end

  defp query_order(order, val) do
    case order do
      "asc" -> Keyword.new([{:asc, val}])
        _   -> Keyword.new([{:desc, val}])
    end
  end

  def filtered_by(query, params) do
    Enum.reduce(params, query, fn({key, value}, query) ->
      case String.downcase(key) do
        "type" ->
          type_filter(value, query)
        "exchange" ->
          exchange_filter(value, query)
        "threshold" ->
          from tx in query,
          where: tx.cents_value >= ^value
        "time" ->
          time_filter(value, query)
        "token" ->
          token_filter(value, query)
        "wallet" ->
          wallet_filter(value, query)
      end
    end)
  end

  def get_highest_txns do
    highest_txns =
      [
        get_highest(BtcTransaction),
        get_highest(EthTransaction)
      ]
      |> Enum.reject(&is_nil/1)

    {:ok, highest_txns}
  end

  defp get_highest(txns) do
    txns
    |> (&(time_filter("1d", &1))).()
    |> highest_by_cents
    |> Repo.all
    |> Enum.at(0)
  end

  defp highest_by_cents(txns) do
    from tx in txns,
    order_by: [desc: tx.cents_value],
    limit: 1
  end

  def create_btc_transaction(attrs) do
    attrs
      |> process_wallet_name
      |> add_symbol
      |> process_cents_value(Tokens.get_btc)
      |> filter_threshold
      |> save_tx("btc")
  end

  def create_eth_transaction(attrs) do
    attrs
      |> process_wallet_name
      |> process_token_amount
      |> add_symbol
      |> process_cents_value(Tokens.get_eth)
      |> filter_threshold
      |> handle_zero_value
      |> save_tx("eth")
  end

  def broadcast({:ok, tx}) do
    tx
    |> (&(JaSerializer.format(TransactionView, &1))).()
    |> (&(TransactionChannel.send_tx("incoming_tx", &1))).()

    {:ok, tx}
  end
  def broadcast({:error, tx}), do: {:error, tx}

  def create_erc20_transaction(attrs) do
    attrs
      |> process_wallet_name
      |> process_token
      |> process_token_value
      |> filter_threshold
      |> handle_zero_value
      |> save_tx("eth")
  end

  defp exchange_filter("all-wallets", query) do
    from tx in query
  end
  defp exchange_filter("exchanges-only", query) do
    from tx in query,
    where: tx.from_name != "unknown wallet" or tx.to_name != "unknown wallet"
  end
  defp exchange_filter(value, query) do
    from tx in query,
    where: tx.from_name == ^value or tx.to_name == ^value
  end

  defp type_filter("erc20", query) do
    from tx in query,
    where: tx.symbol != "BTC" and tx.symbol != "ETH"
  end
  defp type_filter("eth", query) do
    from tx in query,
    where: tx.symbol == "ETH"
  end
  defp type_filter("btc", query) do
    from tx in query,
    where: tx.symbol == "BTC"
  end

  defp time_filter("1d", query) do
    from tx in query,
    where: fragment("to_timestamp(?)::timestamptz >= (NOW() - INTERVAL ?)::timestamptz", tx.timestamp, "24 hour")
  end
  defp time_filter("7d", query) do
    from tx in query,
    where: fragment("to_timestamp(?)::date >= (NOW() - INTERVAL ?)::date", tx.timestamp, "7 day")
  end
  defp time_filter("30d", query) do
    from tx in query,
    where: fragment("to_timestamp(?)::date >= (NOW() - INTERVAL ?)::date", tx.timestamp, "30 day")
  end

  defp token_filter("all", query) do
    from tx in query
  end
  defp token_filter(value, query) do
    from tx in query,
    where: tx.symbol == ^value
  end

  defp wallet_filter(value, query) do
    from tx in query,
    where: tx.from == ^value or tx.to == ^value
  end

  defp save_tx(nil, _), do: {:error, :tx_rejected}
  defp save_tx(attrs, "eth") do
    %EthTransaction{}
    |> EthTransaction.changeset(attrs)
    |> Repo.insert()
    |> broadcast()
  end
  defp save_tx(attrs, "btc") do
    %BtcTransaction{}
    |> BtcTransaction.changeset(attrs)
    |> Repo.insert()
    |> broadcast()
  end
end
