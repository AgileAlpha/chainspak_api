# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChainsparkApi.Repo.insert!(%ChainsparkApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ChainsparkApi.Tokens
alias ChainsparkApi.Accounts
alias ChainsparkApi.Utils.RemoteCSV
alias ChainsparkApi.Utils.Seeds

tokens_url = "https://s3.ca-central-1.amazonaws.com/whalewatch-seeds/tokens.csv"

[
  %{
    name: "USD Coin",
    symbol: "USDC",
    contract_address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    decimals: 6
  },
  %{
    name: "Paxos Standard",
    symbol: "PAX",
    contract_address: "0x8e870d67f660d95d5be530380d0ec0bd388289e1",
    decimals: 18
  }
]
|> Enum.each(&Seeds.store_wallet(&1, :erc20))

RemoteCSV.stream(tokens_url)
  |> CSV.decode(headers: [:name, :symbol, :contract_address, :decimals])
  |> Enum.each(&Seeds.store_token/1)

RemoteCSV.stream("https://s3.ca-central-1.amazonaws.com/sqrly-uploads/EthScan+Top+10k+-+Sheet1.csv")
  |> CSV.decode(headers: [:rank, :_, :address, :name ])
  |> Enum.each(&Seeds.store_wallet(&1, :erc20))

RemoteCSV.stream("https://s3.ca-central-1.amazonaws.com/whalewatch-seeds/btc_wallets.csv")
  |> CSV.decode(headers: [:address, :name])
  |> Enum.each(&Seeds.store_wallet(&1, :btc))

RemoteCSV.stream("https://s3.ca-central-1.amazonaws.com/whalewatch-seeds/wallets.csv")
  |> CSV.decode(headers: [:address, :name])
  |> Enum.each(&Seeds.store_wallet(&1, :erc20))

[
  %{name: "Ethereum", symbol: "ETH", type: :eth, decimals: 18, price: 20000},
  %{name: "Bitcoin", symbol: "BTC", type: :btc, decimals: 8, price: 600000}
]
|> Enum.each(&Tokens.create_token/1)

Accounts.create(%{email: "john.doe@example.com", password: "q1w2e3r4t5"})
