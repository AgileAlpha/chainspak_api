defmodule ChainsparkApi.Repo.Migrations.CreateEntities do
  use Ecto.Migration

  def change do
    create table :entities do
      add :name, :string
      add :tokens, :jsonb, default: "[]"
      add :btc_balance, :bigint
      add :eth_balance, :bigint
      add :token_balance, :bigint

      timestamps()
    end

    create unique_index(:entities, [:name])
  end
end
