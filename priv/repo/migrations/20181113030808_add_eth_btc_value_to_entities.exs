defmodule ChainsparkApi.Repo.Migrations.AddEthBtcValueToEntities do
  use Ecto.Migration

  def change do
    alter table(:entities) do
      add :btc_value, :bigint
      add :eth_value, :bigint
    end
  end
end
