defmodule ChainsparkApi.Repo.Migrations.AddNameToUniqueIndex do
  use Ecto.Migration

  def change do
    drop index(:tokens, [:symbol])
    create unique_index(:tokens, [:symbol, :name])
  end
end
