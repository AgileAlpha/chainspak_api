defmodule ChainsparkApi.Repo.Migrations.UpdateTokenSymbolToCitext do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      modify :symbol, :citext
    end
  end
end
