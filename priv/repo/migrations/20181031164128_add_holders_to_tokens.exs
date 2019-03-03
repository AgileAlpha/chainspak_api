defmodule ChainsparkApi.Repo.Migrations.AddHoldersToTokens do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :holders, :jsonb, default: "[]"  
    end
  end
end
