defmodule ChainsparkApi.Tokens do
  import Ecto.{Query, Changeset}, warn: false
  alias ChainsparkApi.Tokens.Token
  alias ChainsparkApi.Repo

  def list_tokens do
    from(token in Token,
      select: %{
        name: token.name,
        symbol: token.symbol,
        id: token.id,
        type: token.type
      },
      order_by: [asc: :symbol]
    )
    |> Repo.all
  end

  def list_by_symbol do
    from(token in list_erc20_query(),
      select: {token.symbol, token}
    )
    |> Repo.all
  end

  def list_erc20_query do
    from(token in Token,
      where: token.type == ^:erc20
    )
  end

  def list_erc20 do
    list_erc20_query()
    |> Repo.all
  end

  def erc_top_100_by_marketcap do
    from(token in list_erc20_query(),
      where: token.market_cap > 0,
      order_by: [desc: :market_cap],
      limit: 100
    )
    |> Repo.all
  end

  def get_by_address(address) do
     Token
     |> Repo.get_by(contract_address: address)
  end

  def get_by_symbol(nil), do: {:error, nil }
  def get_by_symbol(symbol) do
    case Repo.get_by(Token, symbol: symbol) do
      nil -> {:error, nil }
      token -> {:ok,  token}
    end
  end

  def get_by_symbol_and_name(symbol, name) do
    case Repo.get_by(Token, symbol: symbol, name: name) do
      nil -> {:error, nil }
      token -> {:ok,  token}
    end
  end

  def token_price(address) do
    case get_by_address(address) do
      %Token{price: price} -> price |> to_dollars
      _ -> nil
    end
  end

  def get_btc, do: get_by_symbol("BTC")
  def get_eth, do: get_by_symbol("ETH")

  def eth_price, do: get_eth() |> Map.get(:price) |> to_dollars

  def update_price(%{id: id, price: price}) do
    record = Repo.get(Token, id)
             |>  Ecto.Changeset.change(price: price)

    case Repo.update record do
      {:ok, _struct } -> IO.puts "Successful"
      {:error, _changeset } -> IO.puts "Error"
    end
  end

  def update_token(nil), do: nil
  def update_token({token, %{ "quote" => %{ "USD" => usd_quote }} = args}) do
    data =
      usd_quote
      |> Map.merge(%{
        "circulating_supply"  => args["circulating_supply"] |> maybe_round,
        "total_supply"        => args["total_supply"] |> maybe_round,
        "max_supply"          => args["max_supply"],
        "symbol"              => args["symbol"]
      })
      |> Map.put("price", (usd_quote["price"] * 100) |> round)
      |> Map.put("market_cap", usd_quote["market_cap"] |> round)
      |> Map.put("volume_24h", usd_quote["volume_24h"] |> maybe_round)

    record =
      token
      |> Token.changeset(data)

    case Repo.update record do
      {:ok, _struct } -> IO.puts "Successful"
      {:error, _changeset } -> IO.puts "Error"
    end
  end

  def maybe_round(nil), do: 0
  def maybe_round(amount), do: amount |> round

  @doc """
  Creates or updates a token

  ## Examples

      iex> create_token(%{field: value})
      {:ok, %Token{}}

      iex> create_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token(attrs = %{name: _name, symbol: _symbol, type: _type, decimals: _decimals }) do
    Token.changeset(%Token{}, attrs)
     |> Repo.insert(
        on_conflict: :replace_all,
        conflict_target: [:symbol, :name])
  end

  defp to_dollars(cents) when is_nil(cents), do: nil
  defp to_dollars(cents), do: cents / 100
end
