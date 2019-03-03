defmodule ChainsparkApi.Repo.Migrations.CorvertTxnsWalletNamesToCitext do
  use Ecto.Migration

  def up do
    alter table(:btc_transactions) do
      modify :from_name, :citext
      modify :to_name, :citext
    end

    alter table(:eth_transactions) do
      modify :from_name, :citext
      modify :to_name, :citext
    end
  end

  def down do

    alter table(:btc_transactions) do
      modify :from_name, :string
      modify :to_name, :string
    end

    alter table(:eth_transactions) do
      modify :from_name, :string
      modify :to_name, :string
    end
  end
end
