defmodule ChainsparkApi.Repo.Migrations.ConvertNameColumnsToCitext do
  use Ecto.Migration

  def up do
    alter table(:entities) do
      modify :name, :citext, null: false
    end

    alter table(:wallets) do
      modify :name, :citext
    end
  end

  def down do

    alter table(:entities) do
      modify :name, :string, null: false
    end

    alter table(:wallets) do
      modify :name, :string
    end
  end
end
