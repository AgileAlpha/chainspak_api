defmodule ChainsparkApi.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :contract_address, :binary
      add :name, :string
      add :type, :type
      add :decimals, :integer
      add :symbol, :string
      add :price, :integer

      timestamps()
    end

    create unique_index(:tokens, [:symbol])
    create index :tokens, [:contract_address]
    create index :tokens, [:type]
  end
end
