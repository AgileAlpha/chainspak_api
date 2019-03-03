defmodule ChainsparkApi.Repo.Migrations.AddMetaDataToTokens do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :volume_24h, :bigint
      add :percent_change_24h, :float
      add :percent_change_7d, :float
      add :market_cap, :bigint
      add :circulating_supply, :bigint
      add :total_supply, :bigint
      add :max_supply, :bigint
    end
  end
end
