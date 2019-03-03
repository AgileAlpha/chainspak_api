defmodule ChainsparkApi.Transactions.Util do
  alias ChainsparkApi.Wallets
  alias ChainsparkApi.Tokens

  @eth_threshold 10_000_00
  @btc_threshold 10_000_00
  @erc20_threshold 1_000_00
  @kraken_split "0xfa52274dd61e1643d2205169732f29114bc240b3"

  def handle_zero_value(nil), do: nil
  def handle_zero_value(%{ "value" => 0 } = attrs), do: Map.put(attrs, "value", "0x0")
  def handle_zero_value(attrs), do: attrs

  def to_cents_value(value, price), do: (value * price) |> Kernel.trunc

  def process_token(nil), do: :token_not_found
  def process_token(%{"transfer_log" => transfer_log} = attrs) do
    case Tokens.get_by_address(attrs["to"]) do
      nil ->
        case Tokens.get_by_address(transfer_log["address"]) do
          nil ->
            if (is_split_contract?(transfer_log["address"])) do
              {:ok, eth} = Tokens.get_eth()
              attrs
              |> Map.put("is_token_tx", false)
              |> add_token_details(eth)
            else
              :token_not_found
            end
          token -> add_token_details(attrs, token)
        end
      token -> add_token_details(attrs, token)
    end
  end

  defp is_split_contract?(contract), do: contract == @kraken_split

  def add_token_details(attrs, token) do
    attrs
    |> Map.put("symbol", token.symbol)
    |> Map.put("token_decimals", token.decimals)
    |> Map.put("token_price", token.price || 0)
    |> Map.put("contract_address", token.contract_address)
  end

  def process_token_amount(:token_not_found), do: nil
  def process_token_amount(%{"is_token_tx" => false} = attrs) do
    attrs
    |> Map.put("token_amount", wei_to_eth(attrs["token_amount"]))
  end

  def process_token_value(:token_not_found), do: nil
  def process_token_value(attrs) do
    {token_amount, _} = attrs["token_amount"] |> Integer.parse
    token_amount = token_amount / :math.pow(10, attrs["token_decimals"]) |> round
    cents_value  = token_amount * attrs["token_price"] |> round

    attrs
    |> Map.put("cents_value", cents_value)
    |> Map.put("token_amount", token_amount)
  end

  def filter_threshold(%{"is_token_tx" => true, "cents_value" => cents_value } = attrs) when cents_value >= @erc20_threshold, do: attrs
  def filter_threshold(%{"is_btc_tx" => true, "cents_value" => cents_value } = attrs) when cents_value >= @btc_threshold, do: attrs
  def filter_threshold(%{"is_token_tx" => false, "cents_value" => cents_value }= attrs) when cents_value >= @eth_threshold, do: attrs
  def filter_threshold(_), do: nil

  def wei_to_eth(nil), do: 0
  def wei_to_eth(amount) when is_binary(amount), do: wei_to_eth(String.to_integer(amount))
  def wei_to_eth(amount) do
    amount / :math.pow(10, 18)
    |> round
  end

  def satoshi_to_btc(nil), do: 0
  def satoshi_to_btc(amount) when is_binary(amount), do: satoshi_to_btc(String.to_integer(amount))
  def satoshi_to_btc(amount) when not is_integer(amount), do: 0
  def satoshi_to_btc(amount) do
    amount / :math.pow(10, 8)
    |> round
  end

  def process_cents_value(attrs, {:ok, %{ price: price}}) do
    attrs
    |> Map.put("cents_value", to_cents_value(attrs["token_amount"], price))
  end

  def process_wallet_name(%{ "from" => from, "to" => to }) when from == 0 or to == 0, do: nil
  def process_wallet_name(attrs) do
    from_wallet =
      with {:ok, wallet } <- Wallets.get_by_address(attrs["from"]) do
        wallet.name |> String.capitalize
      end

    to_wallet =
      with {:ok, wallet } <- Wallets.get_by_address(attrs["to"]) do
       wallet.name |> String.capitalize
    end

    attrs
    |> Map.put("from_name", from_wallet)
    |> Map.put("to_name", to_wallet)
  end

  def add_symbol(%{ "is_token_tx" => false } = attrs), do: attrs |> Map.put("symbol", "ETH")
  def add_symbol(%{ "is_btc_tx" => true } = attrs), do: attrs |> Map.put("symbol", "BTC")
  def add_symbol(attrs), do: attrs

  def to_token(value, 0), do: value
  def to_token(nil, nil), do: 0
  def to_token(0, _decimals),    do: 0
  def to_token(_, ""), do: 0
  def to_token(value, decimals) when is_binary(decimals) do
    decimals = String.to_integer(decimals)
    value * :math.pow(10, -decimals) |> round
  end
  def to_token(value, decimals), do: value * :math.pow(10, -decimals) |> round

  def to_int(nil), do: 0
  def to_int(0), do: 0
  def to_int(%Decimal{} = value), do: round_and_convert(value)
  def to_int(decimal) when is_integer(decimal), do: decimal
  def to_int(decimal) when is_float(decimal) do
    decimal
    |> Decimal.from_float
    |> round_and_convert
  end

  defp round_and_convert(%Decimal{} = decimal) do
    decimal
    |> Decimal.round
    |> Decimal.to_integer
  end
end
