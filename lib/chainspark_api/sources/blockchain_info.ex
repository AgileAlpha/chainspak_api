defmodule ChainsparkApi.BlockchainInfo do
  @base_url "https://blockchain.info"

  def query_api(query) do
    case HTTPoison.get(@base_url <> query) do
      {:ok, %HTTPoison.Response{body: body}} ->
        with {:ok, response } <- Poison.decode(body) do
          response
        else
         error -> IO.inspect error
        end
      {:error, _ } -> []
    end
  end

  def get_address(address) do
    case query_api "/rawaddr/#{address}" do
      {:error, _} -> {:error, "invalid address"}
      details -> {:ok, details}
    end
  end

  def get_address_balance(address) do
    %{
      address: address,
      balance: query_api("/q/addressbalance/#{address}")
    }
  end

  def get_exchange_balances(addresses) do
    balances = Task.async_stream(addresses, fn address -> get_address_balance(address) end, timeout: 10000)

    Enum.to_list(balances)
    |> Enum.map(fn {:ok, list } -> list end)
  end
end
