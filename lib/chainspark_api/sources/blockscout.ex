defmodule ChainsparkApi.Blockscout do
  @blockscout_api "https://blockscout.com/eth/mainnet/api"
  @past_days_limit 30

  alias ChainsparkApi.Repo
  alias ChainsparkApi.Tokens.Token

  def query_api(query) do
    case HTTPoison.get(@blockscout_api <> query) do
      {:ok, %HTTPoison.Response{body: body }} ->
        with {:ok, response } <- Poison.decode(body) do
          response["result"]
        else
         error -> IO.inspect error
        end
      {:error, _ } -> []
    end
  end

  def get_wallet_balance(address) do
    query_api("?module=account&action=balance&address=#{address}")
  end

  def get_wallets_balances(addresses) do
    addresses = 
      addresses
      |> Enum.join(",")

    query_api("?module=account&action=balancemulti&address=#{addresses}") || []
  end

  def get_wallet_txns(address) do
    starttimestamp = days_ago_unix(@past_days_limit)

    "?module=account&action=txlist&address=#{address}&page=#{1}&offset=100&starttimestamp=#{starttimestamp}"
    |> query_api
  end

  def get_wallet_tokens(address) do
    query_api("?module=account&action=tokenlist&address=#{address}")
    |> Enum.map(fn token -> 
      case Repo.get_by(Token, contract_address: token["contractAddress"]) do
        nil -> nil
        stored_token -> 
          token |> Map.merge(%{
            "wallet_address" => address, 
            "price" => stored_token.price
          }) 
      end
    end)
    |> Enum.reject( fn token -> is_nil(token) || token["symbol"] == "" end)
  end

  def get_wallet_activity(address) do
    address
    |> get_wallet_txns
    |> mark_activity_level
  end

  def mark_activity_level(txns) do
    txns_per_month = length(txns)

    cond do
      txns_per_month > 60 -> "HIGH"
      txns_per_month < 5  -> "LOW"
      true -> "MED"
    end
  end

  def get_exchange_balance(addresses) do
    addresses
    |> Enum.join(",")
    |> get_wallets_balances
    |> sum_up_balances
  end

  def get_exchange_tokens(addresses) do
    exchange_tokens = Task.async_stream(addresses, fn address -> get_wallet_tokens(address) end, timeout: 10000)

    Enum.to_list(exchange_tokens)
    |> Enum.map(fn {:ok, list} -> list end)
    |> Enum.concat
    |> sum_up_tokens
  end

  def sum_up_balances(nil), do: %{ balance: 0 }
  def sum_up_balances(balances) do
    balances
    |> Enum.reduce(%{}, fn %{ "balance" => balance }, map ->
      unless map["balance"] do
        Map.put(map, "balance", parse_balance(balance))
      else
        Map.update!(map, "balance", &(&1 + parse_balance(balance)))
      end
    end)
  end

  def sum_up_tokens(tokens) do
    tokens
    |> Enum.reduce(%{}, fn token, acc ->
        %{"name" => name, "balance" => balance} = token

        unless acc[name] do
          updated_token = Map.update!(token, "balance", &parse_balance/1)
          Map.put(acc, name, updated_token)
        else
          token =  Map.update(acc[name], "balance", 0, &(&1 + parse_balance(balance)))
          Map.replace!(acc, name, token)
        end
      end)
  end

  def days_ago_unix(days) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-days * (60 * 60 * 24))
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix
  end

  defp parse_balance(nil), do: 0
  defp parse_balance(""), do: 0
  defp parse_balance(value) when is_binary(value) do
    {balance, _}  = value |> Integer.parse
    balance
  end
  defp parse_balance(value), do: value
end
