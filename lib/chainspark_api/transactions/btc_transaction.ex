defmodule ChainsparkApi.Transactions.BtcTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainsparkApi.AddressType
  alias ChainsparkApi.Transactions.BtcTransaction

  schema "btc_transactions" do
    field :to,    AddressType
    field :to_name, :string
    field :hash,  :binary
    field :block_hash, :binary
    field :from,  AddressType
    field :from_name, :string
    field :cents_value, :integer
    field :token_amount, :integer
    field :symbol, :string
    field :timestamp, :integer
    field :value, :integer
  
    timestamps()
  end

  def changeset(%BtcTransaction{} = transaction, attrs) do
    transaction
    |> cast(attrs, [:hash, :symbol, :value, :to, :from, :token_amount, :from_name, :to_name, :cents_value, :timestamp])
    |> validate_required([:hash])
    |> unique_constraint(:hash)
  end

end
