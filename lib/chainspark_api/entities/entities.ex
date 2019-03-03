defmodule ChainsparkApi.Entities do
  import Ecto.Query, warn: false

  alias ChainsparkApi.Wallets.Wallet
  alias ChainsparkApi.Entities.Entity
  alias ChainsparkApi.Repo

  def list_all do
    from(entity in Entity,
      order_by: [asc: :name]
    )
    |> Repo.all
  end

  def create_entity(attrs) do
    Entity.changeset(%Entity{}, attrs)
    |> Repo.insert!(
      on_conflict: :replace_all,
      conflict_target: [:name]
    )
  end

  def get_by_name(name) do
    {:ok, Repo.get_by!(Entity, name: name)}
  end

  def get_eth_addresses(name) do
    from(wallet in Wallet,
      where: wallet.name == ^name and wallet.type == ^:eth,
      select: wallet.address
    )
    |> Repo.all
  end
end
