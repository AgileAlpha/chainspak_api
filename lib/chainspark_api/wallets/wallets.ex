defmodule ChainsparkApi.Wallets do
  import Ecto.Query, warn: false
  alias ChainsparkApi.{Wallets.Wallet, Repo, Blockscout, BlockchainInfo}

  @exchanges [
    "binance",
    "bitfinex",
    "bitstamp",
    "bittrex",
    "gemini",
    "hitbtc",
    "kraken",
    "poloniex"
  ]

  def list_all_addresses do
    Wallet
    |> Repo.all
  end

  def list_aggregate(type) do
    type = case type do
      "erc20" -> :eth
      _ -> type
    end

    from(wallet in Wallet,
      select: %{
        name: wallet.name,
        addresses: fragment("ARRAY_AGG(encode(?, 'escape'))", wallet.address)
      },
      group_by: wallet.name,
      where: wallet.type == ^type and wallet.name in ^@exchanges
    )
    |> Repo.all
  end

  @doc """
  Creates a wallet.

  ## Examples

      iex> create_wallet(%{field: value})
      {:ok, %Wallet{}}

      iex> create_wallet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wallet(attrs \\ %{}) do
    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns a list of wallet addresses given a name
  """
  def list_for_name_and_type(name, type) do
    type = case type do
      "erc20" -> :eth
      _ -> type
    end

    from(wallet in Wallet,
      where: wallet.name == ^name and wallet.type == ^type,
      select: %{ "name" => wallet.name, "address" => wallet.address }
    )
    |> Repo.all
  end

  def list_wallets_query do
    from(wallet in Wallet,
      order_by: [asc: wallet.name],
      distinct: wallet.name
    )
  end

  @doc """
  Returns the list of wallets.

  ## Examples

      iex> list_wallets()
      [%Wallet{}, ...]

  """
  def list_wallets do
    list_wallets_query()
    |> Repo.all
  end

  def list_wallets(type) do
    type = case type do
      "erc20" -> :eth
      _ -> type
    end

    from(wallet in list_wallets_query(),
      where: wallet.type == ^type
    )
    |> Repo.all
  end

  @doc """
  Gets a single wallet.

  Raises `Ecto.NoResultsError` if the Wallet does not exist.

  ## Examples

      iex> get_wallet!(123)
      %Wallet{}

      iex> get_wallet!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wallet!(id), do: Repo.get!(Wallet, id)

  def get_by_address(address) do
    case Repo.get_by(Wallet, address: address) do
         nil -> {:ok, %{name: "Unknown Wallet"}}
      wallet -> {:ok, wallet}
    end
  end

  def get_by_address_with_details(address) do
    details = get_wallet_details(address)

    detailed_wallet =
      case Repo.get_by(Wallet, address: address) do
        nil ->
          %{address: address, name: "Unknown wallet"}
          |> Map.merge(details)
        wallet ->
          wallet
          |> Map.merge(details)
      end

    {:ok, detailed_wallet}
  end

  @doc """
  Updates a wallet.

  ## Examples

      iex> update_wallet(wallet, %{field: new_value})
      {:ok, %Wallet{}}

      iex> update_wallet(wallet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wallet(%Wallet{} = wallet, attrs) do
    wallet
    |> Wallet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Wallet.

  ## Examples

      iex> delete_wallet(wallet)
      {:ok, %Wallet{}}

      iex> delete_wallet(wallet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wallet(%Wallet{} = wallet) do
    Repo.delete(wallet)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking wallet changes.

  ## Examples

      iex> change_wallet(wallet)
      %Ecto.Changeset{source: %Wallet{}}

  """
  def change_wallet(%Wallet{} = wallet) do
    Wallet.changeset(wallet, %{})
  end

  defp get_wallet_details(<< "0x", _rest::binary >> = address) do
    transactions = Blockscout.get_wallet_txns(address)
    %{
      tokens: Blockscout.get_wallet_tokens(address),
      balance: Blockscout.get_wallet_balance(address),
      transactions: transactions,
      activity: Blockscout.mark_activity_level(transactions)
    }
  end
  defp get_wallet_details(address) do
    case BlockchainInfo.get_address(address) do
      {:ok, details} ->
        %{
          tokens: nil,
          balance: details["final_balance"],
          details: details
        }
      {:error, _} ->
        %{
          tokens: nil,
          balance: nil,
          details: nil
        }
    end
  end
end
