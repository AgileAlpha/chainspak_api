defmodule ChainsparkApi.Jobs.Entities do
  use GenServer

  alias ChainsparkApi.Wallets
  alias ChainsparkApi.Blockscout
  alias ChainsparkApi.BlockchainInfo
  alias ChainsparkApi.Tokens
  alias ChainsparkApi.Transactions.Util
  alias ChainsparkApi.Entities

  alias ChainsparkApi.BigQuery

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_next_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    work()
    schedule_next_work()
    {:noreply, state}
  end

  def work do
    tokens = Tokens.list_by_symbol()
    {:ok, btc } = Tokens.get_by_symbol("BTC")
    {:ok, eth } = Tokens.get_by_symbol("ETH")
    process_eth(tokens, eth)
    process_btc(btc)
  end

  def process_eth(tokens, eth) do
    Wallets.list_aggregate(:eth)
    |> Enum.map(&get_tokens/1)
    |> Enum.map(fn entity -> add_token_details(entity, tokens) end)
    |> Enum.map(fn entity -> get_eth_balances(entity, eth) end)
    |> Enum.map(fn entity -> sum_eth_balance(entity, eth) end)
    |> Enum.map(&add_token_balance/1)
    |> Enum.map(&Entities.create_entity/1)
  end

  def process_btc(btc) do
    Wallets.list_aggregate(:btc)
    |> Enum.map(fn entity -> add_btc_wallets(entity, btc) end)
    |> Enum.map(fn entity -> sum_btc_balance(entity, btc) end)
    |> Enum.map(&Entities.create_entity/1)
  end

  def get_tokens(%{ name: name, addresses: addresses } = entity) do
    IO.inspect "Processing: #{ name }"
    exchange_tokens = BigQuery.token_balance(addresses)

    entity
    |> Map.put(:exchange_tokens, exchange_tokens)
  end

  defp add_token_details(%{exchange_tokens: nil} = entity, _tokens) do
    entity
    |> Map.put(:exchange_tokens, [])
  end
  defp add_token_details(%{exchange_tokens: exchange_tokens} = entity, tokens) do
    result =
      exchange_tokens
      |> Enum.map(fn exchange_token ->
        case Enum.find(tokens, fn {_symbol, token } -> token.contract_address == exchange_token.token_address end) do
          nil -> nil
          {_symbol, %{price: 0}} -> nil
          {_symbol, %{price: nil}} -> nil
          {_symbol, token } ->

            balance = Util.to_int(exchange_token.balance)

            percentage_held =
              if token.total_supply != 0,
                do: balance / token.total_supply,
              else: 0

            exchange_token
            |> Map.merge(%{
              contract_address: token.contract_address,
              name: token.name,
              symbol: token.symbol,
              balance: balance,
              total_supply: token.total_supply,
              value: Util.to_int(token.price * balance),
              perc_held: percentage_held
            })
        end
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(fn token -> token.value == 0 or token.perc_held < 0.001 end)

    entity
    |> Map.put(:tokens, result)
  end

  defp add_token_balance(%{ tokens: tokens } = entity) do
    token_value = tokens
                  |> Enum.map(fn token -> token.value end)
                  |> Enum.sum

    entity
    |> Map.put(:token_value, token_value)
  end

  defp get_eth_balances(%{ addresses: addresses } = entity, eth) do
    eth_wallets = Blockscout.get_wallets_balances(addresses)
                  |> Enum.reject(&is_nil/1)
                  |> Enum.map(fn wallet ->
                    balance = wallet["balance"] |> Util.wei_to_eth
                    %{
                      wallet_address: wallet["account"],
                      balance: balance,
                      value: balance * eth.price
                    }
                  end)

    entity
    |> Map.put(:eth_wallets, eth_wallets)
  end

  defp sum_eth_balance(%{ eth_wallets: eth_wallets} = entity, eth) do
    eth_balance =
      eth_wallets
      |> Enum.map(fn wallet -> wallet.balance end)
      |> Enum.sum

    eth_value = eth_balance * eth.price

    entity
    |> Map.put(:eth_balance, eth_balance)
    |> Map.put(:eth_value, eth_value)
  end

  defp add_btc_wallets(%{name: name, addresses: addresses} = entity, btc) do
    IO.puts "Processing #{ name }"
    btc_wallets =
      BlockchainInfo.get_exchange_balances(addresses)
      |> Enum.map(fn wallet ->
        balance = Util.satoshi_to_btc(wallet.balance)
        wallet
        |> Map.put(:wallet_address, wallet.address)
        |> Map.put(:balance, balance)
        |> Map.put(:value, balance * btc.price)
      end)

    entity
    |> Map.put(:btc_wallets, btc_wallets)
  end

  def sum_btc_balance(%{ btc_wallets: btc_wallets } = entity, btc) do
    balance = btc_wallets
              |> Enum.map(fn wallet -> wallet.balance end)
              |> Enum.sum
    value = balance * btc.price

    entity
    |> Map.put(:btc_balance, balance)
    |> Map.put(:btc_value, value)
  end

  defp schedule_next_work do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000)
  end
end
