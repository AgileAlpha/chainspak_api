defmodule ChainsparkApi.Transactions.EthTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias ChainsparkApi.AddressType
  alias ChainsparkApi.Transactions.EthTransaction

  @derive {Jason.Encoder, only: [:to, :from, :symbol]}
  schema "eth_transactions" do
    field :to,    AddressType
    field :to_name, :string
    field :hash,  :binary
    field :block_hash, :binary
    field :from,  AddressType
    field :from_name, :string
    field :value, :binary
    field :contract_address, AddressType
    field :token_amount, :integer
    field :token_decimals, :integer
    field :cents_value, :integer
    field :timestamp, :integer
    field :symbol, :string
  
    timestamps()
  end

  def changeset(%EthTransaction{} = transaction, attrs) do
    transaction
    |> cast(attrs, [:hash, :symbol, :value, :to, :from, :contract_address, :token_amount, :cents_value, :timestamp, :from_name, :to_name, :token_decimals])
    |> validate_required([:hash])
    |> unique_constraint(:hash)
  end
end
