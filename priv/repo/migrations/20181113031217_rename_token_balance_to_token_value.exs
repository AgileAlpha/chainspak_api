defmodule ChainsparkApi.Repo.Migrations.RenameTokenBalanceToTokenValue do
  use Ecto.Migration

  def change do
    rename table(:entities), :token_balance, to: :token_value
  end
end
