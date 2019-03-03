defmodule ChainsparkApi.Repo.Migrations.AddMetaToTransactions do
  use Ecto.Migration

  def change do
    alter table(:btc_transactions) do
      add :from_name, :string, null: true, default: "Unknown wallet"
      add :to_name, :string, null: true, default: "Unknown wallet"
      add :token_amount, :bigint, null: false
      add :symbol, :string, null: false, default: "BTC"
      add :cents_value, :bigint, null: false
      add :timestamp, :integer, null: false
    end

    alter table(:eth_transactions) do
      add :from_name, :string, null: true, default: "Unknown wallet"
      add :to_name, :string, null: true, default: "Unknown wallet"
      add :token_amount, :bigint, null: false
      add :symbol, :string, null: false, default: "BTC"
      add :cents_value, :bigint, null: false
      add :timestamp, :integer, null: false
    end

    create index(:btc_transactions, [:from_name])
    create index(:btc_transactions, [:to_name])
    create index(:btc_transactions, [:to])
    create index(:btc_transactions, [:from])

    create index(:eth_transactions, [:from_name])
    create index(:eth_transactions, [:to_name])
    create index(:eth_transactions, [:to])
    create index(:eth_transactions, [:from])
    create index(:eth_transactions, [:contract_address])
  end
end
