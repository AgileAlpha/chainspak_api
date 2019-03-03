defmodule ChainsparkApi.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainsparkApi.Wallets.Wallet
  alias ChainsparkApi.AddressType

  schema "wallets" do
    field :name, :string
    field :address, AddressType
    field :type, TokenType

    timestamps()
  end

  def changeset(%Wallet{} = exchange, attrs) do
    exchange
    |> cast(attrs, [:name, :address, :type])
    |> validate_required([:address, :type])
    |> unique_constraint(:address)
  end
end
