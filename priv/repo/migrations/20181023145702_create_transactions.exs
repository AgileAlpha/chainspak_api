defmodule ChainsparkApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:eth_transactions) do
      add :hash, :bytea, null: false
      add :block_hash, :bytea, null: true
      add :from, :bytea, null: true
      add :to, :bytea, null: true
      add :value, :bytea, null: true
      add :contract_address, :bytea, null: true

      timestamps()
    end

    create table(:btc_transactions) do
      add :hash, :bytea, null: false
      add :block_hash, :bytea, null: true
      add :from, :bytea, null: true
      add :to, :bytea, null: true
      add :value, :bigint, null: true

      timestamps()
    end

    create unique_index :eth_transactions, [:hash]
    create unique_index :btc_transactions, [:hash]
  end
end
