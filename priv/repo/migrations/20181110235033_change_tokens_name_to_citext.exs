defmodule ChainsparkApi.Repo.Migrations.ChangeTokensNameToCitext do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      modify :name, :citext
    end

    create index :tokens, [:symbol]
  end
end
