defmodule ChainsparkApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION citext"

    create table(:users) do
      add :email, :citext, null: false
      add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])
  end

  def down do
    drop table(:users)
    execute "DROP EXTENSION citext"
  end
end
