defmodule ChainsparkApi.Jobs.TokenHolders do
  use GenServer

  alias ChainsparkApi.Tokens
  alias ChainsparkApi.Wallets
  alias ChainsparkApi.Repo
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

  def work() do
    wallets = Wallets.list_all_addresses

    Tokens.list_erc20()
      |> Enum.map(fn token -> fetch_and_save_holders(token, wallets) end)
  end

  def fetch_and_save_holders(token, wallets) do
    IO.puts "Processing token: #{ token.symbol } [#{token.contract_address}]"

    case BigQuery.token_holders(token.contract_address) do
      nil -> nil
      holders ->
        holders =
          holders
          |> Enum.map(fn holder -> match_holder_name(holder, wallets) end)

        token
        |> Ecto.Changeset.change(holders: holders)
        |> Repo.update!
    end
  end

  defp schedule_next_work do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000)
  end

  defp match_holder_name(holder = %{address: holder_address}, wallets) do
    %{name: name} =
      wallets
      |> Enum.find(%{name: "unknown wallet"}, fn %{address: address} -> address == holder_address end)

    holder |> Map.put(:name, name)
  end
end
