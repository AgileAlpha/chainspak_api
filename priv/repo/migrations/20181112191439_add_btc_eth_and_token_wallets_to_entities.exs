defmodule ChainsparkApi.Repo.Migrations.AddBtcEthAndTokenWalletsToEntities do
  use Ecto.Migration

  def change do
    alter table(:entities) do
      add :btc_wallets, :jsonb, default: "[]"
      add :eth_wallets, :jsonb, default: "[]"
      add :token_wallets, :jsonb, default: "[]"
    end
  end
end
