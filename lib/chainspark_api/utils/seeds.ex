defmodule ChainsparkApi.Utils.Seeds do
  alias ChainsparkApi.Tokens.Token
  alias ChainsparkApi.Wallets.Wallet
  alias ChainsparkApi.Repo

  def store_token(row) do
    {decimals, ""} = Integer.parse(row[:decimals])
    Token.changeset(%Token{}, %{
      name: row[:name] |> String.trim,
      type: :erc20,
      symbol: row[:symbol] |> String.trim,
      contract_address: row[:contract_address] |> String.downcase,
      decimals: decimals,
      price: nil
    }) |> Repo.insert_or_update
  end

  def store_wallet(row = %{name: name}, :erc20) when name !== "" do
    Wallet.changeset(%Wallet{}, %{
      name: name |> format_name,
      address: row[:address],
      type: :eth
    }) |> Repo.insert_or_update
  end

  def store_wallet(row = %{name: name}, :btc) when name !== "" do
    case Regex.scan(~r/wallet:\s([A-Za-z].*)-?.*/, name) do
      [] -> :ok
      [[_, name]] ->
        Wallet.changeset(%Wallet{}, %{
          name: name |> String.trim,
          address: row[:address],
          type: :btc
        }) |> Repo.insert_or_update
    end
  end

  def store_wallet(_, _), do: nil

  defp format_name(name), do: name |> String.split("_") |> Enum.at(0)
end
