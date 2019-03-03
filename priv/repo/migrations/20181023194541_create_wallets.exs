defmodule ChainsparkApi.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    TokenType.create_type
    create table(:wallets) do
      add :name, :string, null: true
      add :address, :binary, null: false
      add :type, :type, null: false, default: "eth"

      timestamps()
    end

    create unique_index :wallets, [:address]
  end
end
