defmodule ChainsparkApi.Repo.Migrations.AddTokenDecimalsToEthTransactions do
  use Ecto.Migration

  def change do
    alter table(:eth_transactions) do
      add :token_decimals, :integer
    end
  end
end
