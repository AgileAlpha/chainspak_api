defmodule ChainsparkApi.Factory do
  use ExMachina.Ecto, repo: ChainsparkApi.Repo

  alias ChainsparkApi.Accounts.User
  alias ChainsparkApi.Wallets.Wallet
  alias ChainsparkApi.Tokens.Token
  alias ChainsparkApi.Transactions.BtcTransaction
  alias ChainsparkApi.Transactions.EthTransaction

  def user_factory do
    password_hash = Comeonin.Bcrypt.hashpwsalt("password12345")
    %User{
      email: "john.doe@example.com",
      password_hash: password_hash
    }
  end

  def wallet_factory do
    %Wallet{
      name: "Binance",
      address: "0xfe9e8709d3215310075d67e3ed32a380ccf451c8",
      type: :eth
    }
  end

  def token_factory do
    %Token{
      symbol: "CMCT",
      contract_address: "0x123",
      decimals: 18,
      type: :erc20,
      name: "Crowd Machine"
    }
  end

  def btc_transaction_factory do
    %BtcTransaction{
      symbol: "BTC",
      from: "1Z",
      to: "1E",
      hash: "123",
      from_name: "Unknown Wallet",
      to_name: "Binance",
      cents_value: 50_000_00,
      token_amount: 100,
      timestamp: :os.system_time(:second)
    }
  end

  def eth_transaction_factory do
    %EthTransaction{
      symbol: "ETH",
      from: "0x123",
      to: "0x234",
      hash: "0x123",
      from_name: "Unknown Wallet",
      to_name: "Binance",
      cents_value: 50_000_00,
      token_amount: 100,
      timestamp: :os.system_time(:second)
    }
  end
end
