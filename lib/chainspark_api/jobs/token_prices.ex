defmodule ChainsparkApi.Jobs.TokenPrices do
  use GenServer

  alias ChainsparkApi.Tokens

  @api_key Application.get_env(:chainspark_api, :coinmcap_api_key)
  @base_url "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=5000"
  @headers [{"X-CMC_PRO_API_KEY", @api_key}]

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
    get_coin_list()
    |> Enum.map(&fetch_stored_coin/1)
    |> Enum.each(&Tokens.update_token/1)
  end

  def fetch_stored_coin(nil), do: nil
  def fetch_stored_coin(%{ "symbol" => symbol, "name" => name } = data) do
    with {:ok, token} <- Tokens.get_by_symbol_and_name(symbol, name)
    do
      {token, data}
    else
      _error -> nil
    end
  end

  def get_coin_list do
    case HTTPoison.get @base_url, @headers do
      {:ok, %HTTPoison.Response{body: body }} ->
        {:ok, response } = Poison.decode(body)
        response["data"]
      {:error, _ } -> []
    end
  end

  defp schedule_next_work do
    Process.send_after(self(), :work, 6 * 60 * 60 * 1000)
  end
end
